-- Curves
hl.curve("workspaceEase", {type = "bezier", points = {{0.05, 0.9}, {0.1, 1.05}}})

hl.curve("easeOutQuint", {type = "bezier", points = {{0.23, 1}, {0.32, 1}}})
hl.curve("easeInOutCubic", {type = "bezier", points = {{0.65, 0.05}, {0.36, 1}}})
hl.curve("linear", {type = "bezier", points = {{0, 0}, {1, 1}}})
hl.curve("almostLinear", {type = "bezier", points = {{0.5, 0.5}, {0.75, 1.0}}})
hl.curve("quick", {type = "bezier", points = {{0.15, 0}, {0.1, 1}}})

-- Dan's
hl.curve("elasticOut", {type = "bezier", points = {{0.2, 1.2}, {0.5, 1}}})

-- Animations
hl.animation({leaf = "global", enabled = true, speed = 10, bezier = "default"})
hl.animation({leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint"})
hl.animation({leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint"})
hl.animation({leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%"})
hl.animation({leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%"})
hl.animation({leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear"})
hl.animation({leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear"})
hl.animation({leaf = "fade", enabled = true, speed = 3.03, bezier = "quick"})
hl.animation({leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint"})
hl.animation({leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade"})
hl.animation({leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade"})
hl.animation({leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear"})
hl.animation({leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"})
hl.animation({leaf = "workspaces", enabled = true, speed = 3.75, bezier = "workspaceEase", style = "slidevert"})
hl.animation({leaf = "specialWorkspaceIn", enabled = true, speed = 3, bezier = "elasticOut", style = "slidevert top 50%"})

-- Config
hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 5,
        border_size = 2,

        col = {
            active_border = {colors = {"rgba(ff8800ee)", "rgba(ff4400ee)"}, angle = 45},
            inactive_border = "rgba(595959aa)",
        },

        allow_tearing = true,

        layout = "dwindle",

        modal_parent_blocking = false,
    },

    scrolling = {
        column_width = 1.0,
    },

    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        -- screen_shader = "/home/adam/.config/hypr/shader.frag"

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
    },

    input = {
        kb_layout = "us",
        -- kb_variant =
        -- kb_model =
        kb_options = TernaryV(Device == "main", "", "altwin:swap_alt_win"),
        -- kb_rules =

        numlock_by_default = true,

        follow_mouse = 1,
        accel_profile = "flat",

        sensitivity = TernaryV(Device == "main", 0, 0.33), -- -1.0 - 1.0, 0 means no modification.

        focus_on_close = 1,

        touchpad =  {
            natural_scroll = true,
        },
    },

    binds = {
        workspace_back_and_forth = true,
        scroll_event_delay = 5,
    },

    cursor = {
        zoom_rigid = true,
        zoom_disable_aa = true,
        zoom_detached_camera = false,
        -- no_warps = true,
    },

    debug = {
        disable_logs = false,
    },

    render = {
        direct_scanout = 1,
    },

    group = {
        group_on_movetoworkspace = true,
    },
})

