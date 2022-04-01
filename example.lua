local wibox = require("wibox")
local gears = require("gears")

local mywibox = wibox {
    width = 200,
    height = 50,
    margin = {
        left = 10,
        right = 0,
        top = 20,
        bottom = 0,
    },
    x = 100,
    y = 100,
    ontop = true,
    visible = true,
    --anchor = wibox.Anchor.TOP + wibox.Anchor.LEFT + wibox.Anchor.RIGHT,
    exclusive = 20,
}

local k = wibox.widget {
    {
        {
            {
                {
                    text = "heyho",
                    widget = wibox.widget.textbox
                },
                margins = 10,
                widget = wibox.container.margin
            },
            bg = "#993333aa",
            shape = gears.shape.circle,
            widget = wibox.container.background
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    },
    bg = "#088888",
    border_width = 2,
    border_color = "#eeee00",
    forced_height = 50,
    widget = wibox.container.background
}

mywibox:setup {
    k,
    layout = wibox.layout.fixed.vertical,
}

gears.timer.start_new(2, function()
    k.bg = "#770077"
    print("set")
    return false
end)

