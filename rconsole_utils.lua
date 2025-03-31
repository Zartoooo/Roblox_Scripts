local color_map = { -- might want to change that, not sure if it works on every executor. it was tested on Potassium
    red = "\x1b[31m",
    blue = "\x1b[34m",
    green = "\x1b[32m",
    yellow = "\x1b[33m",
    white = "\x1b[37m",
    black = "\x1b[30m",
    cyan = "\x1b[36m",
    magenta = "\x1b[35m",
    reset = "\x1b[0m"
}

local function _color(s)
    return s:gsub("%%(%a+)%%", function(color)
        local color_code = color_map[color:lower()]
        if color_code then
            return color_code 
        else
            return "%" .. color
        end
    end) .. color_map.reset
end

local function _rprint(...)
    local args = {...}
    local n = select("#", ...)

    if n == 0 then
        rconsoleprint("")
        return
    end

    if n == 1 then
        rconsoleprint(_color(tostring(args[1])))
        return
    end

    for i = 1, n do
        args[i] = tostring(args[i])
    end

    rconsoleprint(_color(table.concat(args, " ")))
end
