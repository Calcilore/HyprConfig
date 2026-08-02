local function toggle_discord(key) return function()
    local window = hl.get_active_window()
    if window == nil then
        hl.dispatch(hl.dsp.focus({ window = "initialclass:^(discord)$" }))
    elseif window.xwayland then
        return
    end

    hl.dispatch(hl.dsp.send_shortcut({ mods = "CONTROL + SHIFT", key = key, window = "initialclass:^(discord)$" }))
end end

-- Applications
local app_binds = {
    ["SUPER + CONTROL + Return"] = "kitty",
    ["SUPER + CONTROL + E"] = "dolphin",
    ["SUPER + D"] = "rofi -show drun",
    ["SUPER + C"] = "qalculate-qt",
    ["Print"] = 'region=$(slurp) && grim -g "$region" - | tee "/home/adam/Pictures/Screenshots/Screenshot_$(date +\'%Y-%m-%d_%H-%M-%S\').png" | wl-copy',
}

for keys, cmd in pairs(app_binds) do
    hl.bind(keys, hl.dsp.exec_cmd(cmd))
end

-- Hyprland Binds
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + T", hl.dsp.group.toggle())
hl.bind("SUPER + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + Tab", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev())
hl.bind("SUPER + S", hl.dsp.window.set_prop({ prop = "no_screen_share", value = "toggle" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.group.move_window({ forward = false }))
hl.bind("SUPER + SHIFT + right", hl.dsp.group.move_window({ forward = true }))
if Device == "laptop" then
    hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
    hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock & sleep 1; systemctl suspend"))
end

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspace Binds
BindToNumbers("SUPER", function(i) return hl.dsp.focus({ workspace = tostring(i) }) end)
BindToNumbers("SUPER + SHIFT", function(i) return function()
    hl.dispatch(hl.dsp.window.move({ out_of_group = true }))
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end end)

hl.bind("SUPER + Return", hl.dsp.workspace.toggle_special("terminal"))
hl.bind("SUPER + SHIFT + Return", hl.dsp.window.move({ workspace = "special:terminal", follow = false }))
hl.bind("SUPER + E", hl.dsp.workspace.toggle_special("fileman"))
hl.bind("SUPER + SHIFT + E", hl.dsp.window.move({ workspace = "special:fileman", follow = false }))

-- Zoom
local curZoom = hl.get_config("cursor.zoom_factor")
local function zoom(fac)
    hl.config({ cursor = { zoom_factor = math.clamp(curZoom * fac, 1, 240) }})
    curZoom = hl.get_config("cursor.zoom_factor")
end

hl.bind("SUPER + mouse_up", function() zoom(1.5) end, { locked = true })
hl.bind("SUPER + mouse_down", function() zoom(1/1.5) end, { locked = true })
hl.bind("SUPER + CONTROL + mouse_up", function() zoom(1.1) end, { locked = true })
hl.bind("SUPER + CONTROL + mouse_down", function() zoom(1/1.1) end, { locked = true })
hl.bind("SUPER + EQUAL", function() zoom(1.5) end, { locked = true })
hl.bind("SUPER + MINUS", function() zoom(1/1.5) end, { locked = true })
hl.bind("SUPER + SHIFT + EQUAL", function() zoom(0) end, { locked = true })
hl.bind("SUPER + SHIFT + MINUS", function() zoom(0) end, { locked = true })

-- Mouse Hide
local function hide_mouse()
    local visible = hl.get_config("cursor.invisible")
    hl.config({ cursor = { invisible = not visible }})
end

hl.bind("SUPER + Z", function() hide_mouse() end)

-- Media
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {locked = true, repeating = true})
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), {locked = true, repeating = true})
BindMany({"XF86AudioMute", "SUPER + Pause"}, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {locked = true})
BindMany({"XF86AudioMicMute", "SUPER + Scroll_Lock"}, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {locked = true})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), {locked = true, repeating = true})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), {locked = true, repeating = true})

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {locked = true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {locked = true})

hl.on("window.active", function(window, _)
    hl.unbind("Scroll_Lock")
    hl.unbind("Pause")

    if not window.xwayland then
        hl.bind("Scroll_Lock", toggle_discord("M"))
        hl.bind("Pause", toggle_discord("D"))
    end
end)

-- Submaps
hl.bind("SUPER + P", hl.dsp.submap("capture"))
hl.define_submap("capture", function()
    hl.bind("SUPER + P", hl.dsp.submap("reset"))
end)

