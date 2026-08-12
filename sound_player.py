#!/usr/bin/env python3
# This file is definetly not programmed by AI idk what you are on about

import os
import queue
import signal
import sys

import numpy as np
import sounddevice as sd
import soundfile as sf


FIFO_PATH = sys.argv[1] if len(sys.argv) > 1 else "/tmp/sound-server"
SEARCH_DIR = "/home/home/adam/.config/hypr/sounds"

SAMPLE_RATE = 44100
CHANNELS = 2
MAX_VOICES = 128
BLOCK_SIZE = 128


class Voice:
    def __init__(self, samples):
        self.samples = samples
        self.position = 0


class SoundServer:
    def __init__(self):
        self.sounds = {}
        self.voices = []
        self.commands = queue.SimpleQueue()
        self.running = True

    def load_sound(self, name, filename):
        samples, samplerate = sf.read(
            filename,
            dtype="float32",
            always_2d=True,
        )

        if samplerate != SAMPLE_RATE:
            raise RuntimeError(
                f"{filename}: expected {SAMPLE_RATE} Hz, "
                f"got {samplerate} Hz"
            )

        if samples.shape[1] == 1:
            samples = np.repeat(samples, 2, axis=1)
        elif samples.shape[1] != CHANNELS:
            samples = samples[:, :CHANNELS]

        self.sounds[name] = samples

        print(f"Loaded {name}: {len(samples)} frames")

    def play(self, name, volume=1.0):
        samples = self.sounds.get(name)

        if samples is None:
            print(f"Unknown sound: {name}")
            return

        if len(self.voices) >= MAX_VOICES:
            self.voices.pop(0)

        if volume != 1.0:
            samples = samples * volume

        self.voices.append(Voice(samples))

    def process_commands(self):
        while True:
            try:
                command = self.commands.get_nowait()
            except queue.Empty:
                break

            if command[0] == "play":
                _, name, volume = command
                self.play(name, volume)

    def audio_callback(self, outdata, frames, time, status):
        if status:
            print(f"Audio status: {status}")

        self.process_commands()

        outdata.fill(0)

        remaining_voices = []

        for voice in self.voices:
            start = voice.position
            end = min(start + frames, len(voice.samples))
            count = end - start

            if count > 0:
                outdata[:count] += voice.samples[start:end]
                voice.position = end

            if voice.position < len(voice.samples):
                remaining_voices.append(voice)

        self.voices = remaining_voices

        np.clip(outdata, -1.0, 1.0, out=outdata)

    def fifo_loop(self):
        if not os.path.exists(FIFO_PATH):
            os.mkfifo(FIFO_PATH, 0o600)

        print(f"Listening on {FIFO_PATH}")

        # Open read/write so we don't repeatedly hit EOF when
        # the Lua side closes its writer.
        with open(FIFO_PATH, "r") as fifo:
            while self.running:
                line = fifo.readline()

                if not line:
                    continue

                self.handle_command(line.strip())

    def handle_command(self, command):
        parts = command.split()

        if not parts:
            return

        if parts[0] == "play":
            if len(parts) < 2:
                return

            name = parts[1]
            volume = float(parts[2]) if len(parts) >= 3 else 1.0

            self.commands.put(("play", name, volume))

        elif parts[0] == "quit":
            self.running = False

    def start(self):
        import threading

        threading.Thread(
            target=self.fifo_loop,
            daemon=True,
        ).start()

        self.audio_stream = sd.OutputStream(
            samplerate=SAMPLE_RATE,
            blocksize=BLOCK_SIZE,
            channels=CHANNELS,
            dtype="float32",
            callback=self.audio_callback,
        )

        self.audio_stream.start()

        print("Audio server running.")

        try:
            while self.running:
                signal.pause()
        except KeyboardInterrupt:
            pass

        self.stop()

    def stop(self):
        self.running = False

        if hasattr(self, "audio_stream"):
            self.audio_stream.stop()
            self.audio_stream.close()

        if os.path.exists(FIFO_PATH):
            os.unlink(FIFO_PATH)


def main():
    server = SoundServer()

    # Sounds are loaded once at startup.
    for root, _dirs, files in os.walk(SEARCH_DIR):
        for file in files:
            path = os.path.join(root, file)
            server.load_sound(path[len(SEARCH_DIR) + 1:], path)

    # server.load_sound("key_down", "key_down.wav")
    # server.load_sound("key_up", "key_up.wav")

    server.start()


if __name__ == "__main__":
    main()

