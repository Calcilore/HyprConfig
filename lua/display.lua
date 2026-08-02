Display_1 = "DP-1"
Display_2 = "HDMI-A-1"

hl.monitor({
    output = Display_1,
    mode = "2560x1440@165",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = Display_2,
    mode = "1680x1050@60",
    position = "-1680x390",
    scale = 1,
})

