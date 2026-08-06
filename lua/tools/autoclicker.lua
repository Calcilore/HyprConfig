local autoclick_mode = false
local autoclick_toggle = false
local autoclicking_left = false
local autoclicking_right = false
local left_click_down = false
local right_click_down = false

local autoclick_timer = hl.timer(function()
    if autoclicking_left then
        hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "mouse:272", state = TernaryV(left_click_down, "up", "down") }))
        left_click_down = not left_click_down
    end
    if autoclicking_right then
        hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "mouse:273", state = TernaryV(right_click_down, "up", "down") }))
        right_click_down = not right_click_down
    end
end, { timeout = 1000.0 / 30.0 / 2.0, type = "repeat" })

autoclick_timer:set_enabled(false)

local function change_autoclicker(on, right) return function()
    if autoclick_toggle then
        if right then
            autoclicking_right = not autoclicking_right
        else
            autoclicking_left = not autoclicking_left
        end
    else
        if right then
            autoclicking_right = on
        else
            autoclicking_left = on
        end
    end

    autoclick_timer:set_enabled(autoclicking_left or autoclicking_right)
end end

local function keybind(toggle) return function()
    if toggle then
        if autoclick_mode then
            autoclick_mode = not autoclick_toggle
        else
            autoclick_mode = not autoclick_mode
        end
    else
        autoclick_mode = not autoclick_mode
    end

    hl.unbind("mouse:272")
    hl.unbind("mouse:273")

    if autoclick_mode then
        autoclick_toggle = toggle
        hl.bind("mouse:272", change_autoclicker(true, false))
        hl.bind("mouse:273", change_autoclicker(true, true))
        if not toggle then
            hl.bind("mouse:272", change_autoclicker(false, false), { release = true })
            hl.bind("mouse:273", change_autoclicker(false, true), { release = true })
        end
    else
        autoclick_toggle = false
        change_autoclicker(false, false)()
        change_autoclicker(false, true)()
    end
end end

hl.bind("SUPER + A", keybind(false))
hl.bind("SUPER + SHIFT + A", keybind(true))

