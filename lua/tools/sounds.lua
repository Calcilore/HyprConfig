local SOUNDS_PATH = os.getenv("HOME") .. "/.config/hypr/sounds/" -- must have / at end of line

local sound_pipe = nil
hl.timer(function() sound_pipe = io.open("/tmp/sound-server", "w") end, { type = "oneshot", timeout = 1000 })

hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/sound_player.py")
end)

local function play_sound(path, state)
    if sound_pipe == nil then
        return
    end

    path = path .. TernaryV(state, "/down", "/up")
    local sound
    while true do
        sound = RandomChoice(ListDir(SOUNDS_PATH .. path))
        if sound ~= "mao.ogg" or math.random() < 0.01 then
            break
        end
    end

    sound = path .. "/" .. sound

    sound_pipe:write("play " .. sound .. "\n")
    sound_pipe:flush()
end

hl.on("input.keyboard.key", function(_, _, state)
    if state ~= 0 and state ~= 1 then
        return
    end

    play_sound("keyboard/normal", state ~= 0)
end)

local function on_mouse(_, state) return function()
    play_sound("mouse", state)
end end

for i = 0, 2 do
    hl.bind("mouse:" .. tostring(272 + i), on_mouse(i, true), { non_consuming = true, ignore_mods = true, dont_inhibit = true })
    hl.bind("mouse:" .. tostring(272 + i), on_mouse(i, false), { non_consuming = true, ignore_mods = true, dont_inhibit = true, release = true })
end

