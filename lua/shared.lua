function BindToNumbers(bind, callback)
    for i = 1, 11 do
        if i == 10 then
            hl.bind(bind .. " + 0", callback(i))
        elseif i == 11 then
            hl.bind(bind .. " + grave", callback(i))
        else
            hl.bind(bind .. " + " .. i, callback(i))
        end
    end
end

function math.clamp(x,a,b)
    return math.min( math.max( x, a ), b )
end

function BindMany(binds, callback, extra)
    for _, bind in pairs(binds) do
        hl.bind(bind, callback, extra)
    end
end

function FizzBuzz()
    for i = 1, 100 do
        local fizz = i % 3 == 0
        local buzz = i % 5 == 0
        local timeout = i * 100

        if fizz and buzz then
            hl.notification.create({text = "fizzbuzz", timeout = timeout})
        elseif fizz then
            hl.notification.create({text = "fizz", timeout = timeout})
        elseif buzz then
            hl.notification.create({text = "buzz", timeout = timeout})
        else
            hl.notification.create({text = tostring(i), timeout = timeout})
        end
    end
end

function Command(command)
    local handle = io.popen(command)
    if handle then
        local output = handle:read("*a") -- Read all stdout
        handle:close()

        -- remove the newline at the end if it exists
        -- Combining this and the line after actually has differing behaviour, do not change it
        output = output:gsub("%s+$", "")
        return output
    end

    return nil
end

function ListDir(dir)
    local t = {}
    for line in io.popen("ls -pa " .. dir .. " | grep -v /"):lines() do
        table.insert(t, line)
    end
    return t
end

function RandomChoice(t)
    return t[math.random(#t)]
end

function TableToString(table)
    if type(table) ~= "table" then
        return tostring(table)
    end

    local output = "{ "
    local first = true
    for k, v in pairs(table) do
        if first then
            first = false
        else
            output = output .. ", "
        end
        output = output .. TableToString(k) .. " = " .. TableToString(v)
    end

    return output .. " }"
end

function Notif(message, timeout)
    if timeout == nil then
        timeout = 3000
    end

    hl.notification.create({text = tostring(message), timeout = timeout})
end

function TernaryV(condition, a, b)
    if condition then
        return a
    else
        return b
    end
end

function TernaryF(condition, a, b)
    if condition then
        return a()
    else
        return b()
    end
end

function Trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function getDeviceName()
    local hostname = io.open("/etc/hostname", "r")
    if hostname == nil then
        return "main"
    end

    local name = Trim(hostname:read("*a"))
    if name == "red-arch-laptop" then
        return "laptop"
    end

    return "main"
end

Device = getDeviceName()

