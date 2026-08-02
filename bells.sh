#!/bin/sh

handle() {
    if [[ $1 == *bell* ]];
    then
        ffplay -autoexit -nodisp /home/adam/Music/squish.mp3 &
    fi
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle “$line”; done

