if hl.plugin.dynamic_cursors == nil then
    return
end

local app_shape_rules = {
    ["Uncanny Cat Golf"] = { clientside = { rotate = { length = 48, offset = 45.0 } } },
    steam = { clientside = { rotate = { length = 28, offset = 25 } } }
}

local global_shape_rules = {
    crosshair = { rotate = { length = 0 } },
    cell = { rotate = { length = 0 } },
    all_scroll = { rotate = { length = 0 } },
    all_resize = { rotate = { length = 0 } },
}

hl.config({plugin = {
    dynamic_cursors = {
        enabled = true,

        -- sets the cursor behaviour, supports these values:
        -- tilt    - tilt the cursor based on x-velocity
        -- rotate  - rotate the cursor based on movement direction
        -- stretch - stretch the cursor shape based on direction and velocity
        -- none    - do not change the cursors behaviour
        mode = "rotate",

        -- minimum angle difference in degrees after which the shape is changed
        -- smaller values are smoother, but more expensive for hw cursors
        threshold = 2,

        -- for mode = rotate
        rotate = {
            -- length in px of the simulated stick used to rotate the cursor
            -- most realistic if this is your actual cursor size
            length = 24,

            -- clockwise offset applied to the angle in degrees
            -- this will apply to ALL shapes
            offset = 0.0,
        },

        -- for mode = tilt
        tilt = {

            -- controls how powerful the tilt is, the lower, the more power
            -- this value controls at which speed (px/s) the full tilt is reached
            -- the full tilt being 60° in both directions
            limit = 5000,

            -- relationship between speed and tilt, supports these values:
            -- linear             - a linear function is used
            -- quadratic          - a quadratic function is used (most realistic to actual air drag)
            -- negative_quadratic - negative version of the quadratic one, feels more aggressive
            -- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
            activation = "negative_quadratic",

            -- time window (ms) over which the speed is calculated
            -- higher values will make slow motions smoother but more delayed
            window = 100,
        },

        -- for mode = stretch
        stretch = {

            -- controls how much the cursor is stretched
            -- this value controls at which speed (px/s) the full stretch is reached
            -- the full stretch being twice the original length
            limit = 1000,

            -- relationship between speed and stretch amount, supports these values:
            -- linear             - a linear function is used
            -- quadratic          - a quadratic function is used
            -- negative_quadratic - negative version of the quadratic one, feels more aggressive
            -- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
            activation = "quadratic",

            -- time window (ms) over which the speed is calculated
            -- higher values will make slow motions smoother but more delayed
            window = 100,
        },

        -- configure shake to find
        -- magnifies the cursor if its is being shaken
        shake = {

            -- enables shake to find
            enabled = true,

            -- controls how soon a shake is detected
            -- lower values mean sooner
            threshold = 6.0,

            -- magnification level immediately after shake start
            base = 4.0,
            -- magnification increase per second when continuing to shake
            speed = 4.0,
            -- how much the speed is influenced by the current shake intensitiy
            influence = 0.0,

            -- maximal magnification the cursor can reach
            -- values below 1 disable the limit (e.g. 0)
            limit = 0.0,

            -- time in millseconds the cursor will stay magnified after a shake has ended
            timeout = 2000,

            -- show cursor behaviour `tilt`, `rotate`, etc. while shaking
            effects = true,

            -- enable ipc events for shake
            -- see the `ipc` section below
            ipc = false,
        },

        -- use hyprcursor to get a higher resolution texture when the cursor is magnified
        -- see the `hyprcursor` section below
        hyprcursor = {

            -- use nearest-neighbour (pixelated) scaling when magnifing beyond texture size
            -- this will also have effect without hyprcursor support being enabled
            -- 0 / false - never use pixelated scaling
            -- 1 / true  - use pixelated when no highres image
            -- 2         - always use pixleated scaling
            nearest = true,

            -- enable dedicated hyprcursor support
            enabled = true,

            -- resolution in pixels to load the magnified shapes at
            -- be warned that loading a very high-resolution image will take a long time and might impact memory consumption
            -- -1 means we use [normal cursor size] * [shake:base option]
            resolution = -1,

            -- shape to use when clientside cursors are being magnified
            -- see the shape-name property of shape rules for possible names
            -- specifying clientside will use the actual shape, but will be pixelated
            fallback = "clientside",
        },
    },
}})

for shape, rule in pairs(global_shape_rules) do
    rule.shape = shape
end

for _, rules in pairs(app_shape_rules) do
    for shape, rule in pairs(rules) do
        rule.shape = shape
    end
end

local function apply_rules(focused_app)
    for _, rule in pairs(global_shape_rules) do
        hl.plugin.dynamic_cursors.shape_rule(rule)
    end

    if app_shape_rules[focused_app] == nil then
        return
    end

    for _, rule in pairs(app_shape_rules[focused_app]) do
        hl.plugin.dynamic_cursors.shape_rule(rule)
    end
end

apply_rules(nil)

local last_focused_class = nil
local function on_window_change(window)
    -- fun fact, when you switch workspaces, hyprland still says you are focusing the window on the
    -- workpace you were at before if you dont focus a window in the new workspace
    -- So we only use the window if its on the current workspace
    local open_workspace = hl.get_active_special_workspace()
    if open_workspace == nil then open_workspace = hl.get_active_workspace() end

    local class
    if window == nil or window.workspace ~= open_workspace then
        class = nil
    else
        class = window.initial_class
    end

    -- nothing changed, we do nothing
    if class == last_focused_class then
        return
    end

    Notif("Cursor refresh " .. tostring(class))

    -- Clear rules which will not be overridden by apply_rules
    local focused_rules = app_shape_rules[last_focused_class]
    if focused_rules ~= nil then
        for shape, _ in pairs(focused_rules) do
            if global_shape_rules[shape] == nil then
                hl.plugin.dynamic_cursors.shape_rule({ shape = shape })
            end
        end
    end

    -- apply all rules again
    apply_rules(class)
    last_focused_class = class
end

-- hl.timer(function() on_window_change(hl.get_active_window()) end, { timeout = 1000, type = "repeat" })
hl.on("window.active", on_window_change)
hl.on("window.destroy", function() on_window_change(hl.get_active_window()) end)

