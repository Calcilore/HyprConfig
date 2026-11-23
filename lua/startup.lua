local startup_commands = {
    "systemctl --user start hyprpolkitagent",
    "dunst",
    "hyprctl setcursor rose-pine-hyprcursor-center 32",
    "hyprpm reload -n",
    "bash /home/adam/Documents/dotfiles/recommit.sh",
    "quickshell -c activate_linux",
    "~/.config/hypr/bells.sh",
    "ashell",
    "XDG_MENU_PREFIX=arch- kbuildsycoca6",
}

if Device == "main" then
    table.insert(startup_commands, "shaderbg --fps 1 " .. Display_1 .. " ~/.config/hypr/shaders/number_clock_blanaced_ternary.frag")
    table.insert(startup_commands, "shaderbg --fps 1 " .. Display_2 .. " ~/.config/hypr/shaders/number_clock_base_6.frag")
    table.insert(startup_commands, "shaderbg --fps 1 " .. Display_3 .. " ~/.config/hypr/shaders/number_clock_base_8.frag")
    table.insert(startup_commands, "shaderbg --fps 1 " .. Display_4 .. " ~/.config/hypr/shaders/number_clock_base_2.frag")
end

local delay_startup_commands = {
    "corectrl --minimize-systray",
    "flatpak run com.github.wwmm.easyeffects",
    "flatpak run org.mozilla.Thunderbird",
    "kitty",
    "dolphin",
    "gpu-screen-recorder -w DP-1 -c mkv -a 'app-inverse:WEBRTC VoiceEngine' -r 300 -o '" .. ReplayFolder .. "'",
}

local env_vars = {
    XCURSOR_SIZE = 32,
    HYPRCURSOR_SIZE = 32,
    XCURSOR_THEME = "BreezeX-RoséPine-Center",
    QT_QPA_PLATFORMTHEME = "kde",
}

hl.on("hyprland.start", function ()
    for _, cmd in ipairs(startup_commands) do
        hl.exec_cmd(cmd);
    end

    for _, cmd in ipairs(delay_startup_commands) do
        hl.exec_cmd("sleep 5 && " .. cmd);
    end
end)

for k, v in pairs(env_vars) do
    hl.env(k, v)
end

