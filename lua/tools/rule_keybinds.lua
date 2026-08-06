local rules = {}
local rule_funcs = {}

local function split(str, sep)
    local result = {}
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, part)
    end
    return result
end

local function save_save()
    local save_file = io.open(os.getenv("HOME") .. "/.config/hypr/perms.conf", "w")
    if save_file == nil then
        hl.notification.create({text = "Failed to write perms.conf", timeout = 10000})
        return
    end

    for type, list in pairs(rules) do
        for class, rule in pairs(list) do
            if rule:is_enabled() then
                save_file:write(type .. "|" .. class .. "\n")
            end
        end
    end

    save_file:flush()
    save_file:close()
end

local function load_save()
    local save_file = io.open(os.getenv("HOME") .. "/.config/hypr/perms.conf", "r")
    if save_file == nil then
        return
    end

    for line in save_file:lines() do
        local spl = split(line, "|")

        local rule = rule_funcs[spl[1]](spl[2])
        rules[spl[1]][spl[2]] = rule
    end

    save_file:close()
end

local function create_perm_save_bind(type, create_rule, toggle_on, toggle_off, extra_remove) return function()
    local window = hl.get_active_window()
    if window == nil then
        return
    end

    local class = window.initial_class
    local rule = rules[type][class]

    if rule == nil then
        rules[type][class] = create_rule(class)
        toggle_on(class)
        hl.notification.create({text = "class " .. class .. " has rule now", timeout = 5000})
    elseif rule:is_enabled() then
        rule:set_enabled(false)
        toggle_off(class)
        hl.notification.create({text = "class " .. class .. " no longer has rule now", timeout = 5000})
    else
        rule:set_enabled(true)
        toggle_on(class)
        hl.notification.create({text = "class " .. class .. " has rule now", timeout = 5000})
    end

    for _, typ in ipairs(extra_remove) do
        rule = rules[typ][class]
        if rule ~= nil then
            rule:set_enabled(false)
        end
    end

    save_save()
end end

-- Bind Creastion Function
local function register_perm_save_bind(name, bind, rule, toggle_on, toggle_off, extra_remove)
    local function get_rule(class)
        rule["match"] = { initial_class = "^(" .. class .. ")$" }
        rule["name"] = "kb_" .. name .. "_" .. class
        return hl.window_rule(rule)
    end

    hl.bind(bind, create_perm_save_bind(name, get_rule, function(_) hl.dispatch(toggle_on) end, function(_) hl.dispatch(toggle_off) end, extra_remove))

    rule_funcs[name] = get_rule
    rules[name] = {}
end

register_perm_save_bind("float", "SUPER + SHIFT + V", { float = true }, hl.dsp.window.float({ action = "on" }), hl.dsp.window.float({ action = "off" }), {})
register_perm_save_bind("fullscreen", "SUPER + SHIFT + F", { fullscreen = true }, hl.dsp.window.fullscreen({ action = "set" }), hl.dsp.window.fullscreen({ action = "unset" }), {})
register_perm_save_bind("immediate", "SUPER + SHIFT + I", { immediate = true }, function() end, function() end, {})

-- Workspace Bind
for i = 1, 11 do
    local bind = "SUPER + ALT + "
    if i == 10 then
        bind = bind .. "0"
    elseif i == 11 then
        bind = bind .. "grave"
    else
        bind = bind .. i
    end

    local extra_remove_workspace_binds = {}
    for j = 1, 11 do
        if j ~= i then
            table.insert(extra_remove_workspace_binds, "workspace" .. j)
        end
    end

    register_perm_save_bind("workspace" .. i, bind, { workspace = i .. " silent" }, hl.dsp.window.move({ workspace = tostring(i), follow = false }), function() end, extra_remove_workspace_binds)
end

-- Extra Things
load_save()

