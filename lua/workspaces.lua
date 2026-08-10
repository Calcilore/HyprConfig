-- Monitor rules
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = Display_1 })
end

hl.workspace_rule({ workspace = "11", monitor = Display_2 })

-- Only have gaps when there is more than one window
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ suppress_event = "maximize" })

-- Window Rules
hl.window_rule({ match = { class = "^io.github.Qalculate.qalculate-qt$" }, float = true, center = true, size = {360, 800} })

-- Jetbrains
hl.window_rule({ match = { class = "^jetbrains-" }, focus_on_activate = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^(?!win)", float = true }, dim_around = true, center = true })
hl.window_rule({ match = { class = "^jetbrains-", title = "^win" }, no_anim = true, no_initial_focus = true, rounding = 0 })

-- Terminal
hl.window_rule({ match = { class = "^(kitty|org\\.kde\\.konsole)$" }, group = "set", workspace = "special:terminal silent" })

-- File Manager
hl.window_rule({ match = { class = "^org.kde.dolphin$" }, workspace = "special:fileman silent" })

-- Steam
hl.window_rule({ match = { class = "^steam$" }, group = "set" })

-- Brave
hl.window_rule({ match = { initial_title = ".* is sharing a window.$" }, workspace = "special:hidden silent" })

