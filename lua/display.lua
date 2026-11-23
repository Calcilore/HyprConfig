if Device == "main" then
    Display_1 = "DP-1"     -- Right (Main) Monitor
    Display_2 = "HDMI-A-1" -- Left Monitor
    Display_3 = "DP-2"     -- Top Left Monitor
    Display_4 = "DP-3"     -- Top Right Monitor

    hl.monitor({
        output = Display_1,
        mode = "2560x1440@165",
        position = "0x0",
        scale = 1,
        vrr = 1,
    })

    hl.monitor({
        output = Display_2,
        mode = "1680x1050@60",
        position = "-1680x390",
        scale = 1,
    })

    hl.monitor({
        output = Display_3,
        mode = "1920x1200@59.95Hz",
        position = "-1920x-810",
        scale = 1,
    })

    hl.monitor({
        output = Display_4,
        mode = "1920x1080@60.00Hz",
        position = "0x-1080",
        scale = 1,
    })
else
    Display_1 = "eDP-1"
    Display_2 = "HDMI-A-1"

    hl.monitor({
        output = Display_1,
        mode = "1920x1080@60",
        position = "0x0",
        scale = 1,
    })
end

