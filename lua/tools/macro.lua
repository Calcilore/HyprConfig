-- recording
local is_recording = false
local recording_first = true
local recording_pressed = false
local start_time = tonumber(0)
local recording = {}

-- playback
local is_playbacking = false
local playback_timers = {}

local function input_logic(state, time)
    if not is_recording then
        return false
    end

    if recording_first then
        recording_first = false
        return false
    end

    if not recording_pressed then
        if state ~= 1 then
            return false
        end

        recording_pressed = true
        start_time = time - 1 -- minus 1 bc timers have a min wait time of 1
    end

    return true
end

hl.on("input.keyboard.key", function(key, time, state)
    if not input_logic(state, time) then
        return
    end

    -- Notif(state .. "ing: " .. tostring(key))
    table.insert(recording, { type = "keyboard", time = time - start_time, key = key, state = state })
end)

-- local function on_mouse(click, state) return function()
--     if not input_logic(state)
-- end end
--
-- for i = 0, 2 do
--     hl.bind("mouse:" .. tostring(272 + i), on_mouse(i, 0), { non_consuming = true })
--     hl.bind("mouse:" .. tostring(272 + i), on_mouse(i, 1), { non_consuming = true, release = true })
-- end

hl.bind("SUPER + SHIFT + O", function()
    if not is_recording then
        Notif("Started recording")
        is_recording = true
        recording_first = true
        recording_pressed = false
        recording = {}
    else
        Notif("Stopped recording")
        is_recording = false

        -- remove super shift o from recording, we assume it is the last 3 keys pressed bc im lazy
        table.remove(recording, #recording)
        table.remove(recording, #recording)
        table.remove(recording, #recording)
    end
end)

hl.bind("SUPER + O", function()
    if is_playbacking then
        for _, timer in ipairs(playback_timers) do
            timer:set_enabled(false) -- trust me, no memory leak here, probably idk
        end

        playback_timers = {}
        is_playbacking = false
        Notif("Stopped playback")
        return
    end

    Notif("Started playback")
    is_playbacking = true

    -- Notif(TableToString(recording))
    local mods_g = { Shift = false, Ctrl = false, Alt = false, Super = false }
    local last_time = 0

    for _, event in ipairs(recording) do
        last_time = math.max(last_time, event.time)

        -- Store modifiers
        if event.state ~= 2 then
            if event.key == 50 then
                mods_g.Shift = event.state ~= 0
            elseif event.key == 37 then
                mods_g.Ctrl = event.state ~= 0
            elseif event.key == 64 then
                mods_g.Alt = event.state ~= 0
            elseif event.key == 133 then
                mods_g.Super = event.state ~= 0
            end
        end

        local mods = ""
        local seperator = false
        for key, pressed in pairs(mods_g) do
            if pressed then
                if seperator then
                    mods = mods .. " + "
                else
                    seperator = true
                end

                mods = mods .. key
            end
        end

        -- Press keys
        table.insert(playback_timers, hl.timer(function()
            local state
            if event.state == 0 then
                state = "up"
            elseif event.state == 1 then
                state = "down"
            else
                state = "repeat"
            end

            -- Notif(state .. "ing: " .. mods .. " + " .. tostring(event.key))
            hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = "code:" .. tostring(event.key), state = state }))
        end, { type = "oneshot", timeout = event.time }))
    end

    hl.timer(function()
        is_playbacking = false
        Notif("Finished playback")
    end, { type = "oneshot", timeout = last_time })
end)

