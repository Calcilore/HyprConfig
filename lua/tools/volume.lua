local VOLUME_CHANGE = 5 -- Percentage change of volume per bind

function DspChangeVolume(dir) return function() ChangeVolume(dir) end end
function ChangeVolume(dir)
    -- use Command so it waits for the process to exit
    Command("wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. tostring(VOLUME_CHANGE) .. "%" .. dir)
    local volume = string.gsub(Command("wpctl get-volume @DEFAULT_AUDIO_SINK@"), "Volume: ", "")
    Notif("Set volume to: " .. (tonumber(volume) * 100) .. "%", 1000, false)
end

local function do_volume(dir) return function()
    local window = hl.get_active_window()
    if window == nil then
        ChangeVolume(dir)
        return
    end

    local sink_inputs = Command("pactl list sink-inputs")

    -- Go through each input until we find the correct one
    local pattern = 'Sink Input #([0-9]+).-Volume:.-([0-9]+)%%.-application.process.id = "([0-9]+)"'
    local search_point, sink_id, volume, pid = 0, nil, nil, nil
    while true do
        _, search_point, sink_id, volume, pid = string.find(sink_inputs, pattern, search_point)
        if search_point == nil then
            Notif("Window does not play sounds!", 1000, false)
            return
        end

        if window.pid == tonumber(pid) then
            break
        end
    end

    hl.exec_cmd("pactl set-sink-input-volume " .. sink_id .. " " .. dir .. tostring(VOLUME_CHANGE) .. "%")

    -- Display volume change to user
    volume = tonumber(volume)
    if dir == "-" then
        volume = volume - VOLUME_CHANGE
    else
        volume = volume + VOLUME_CHANGE
    end

    Notif("Set volume for " .. window.title .. " to " .. tostring(volume), 1000, false)
end end

hl.bind("SUPER + SHIFT + mouse_up", do_volume("+"))
hl.bind("SUPER + SHIFT + mouse_down", do_volume("-"))

