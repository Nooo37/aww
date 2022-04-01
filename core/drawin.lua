local gears_obj = require("gears.object")
local wau = require("wau")
local con = require("con")

local drawin, meta = awesome._shim_fake_class()
local drawins = setmetatable({}, {__mode="v"})

local function new_drawin(_, args)
    local ret = gears_obj()
    ret.data = ret._private -- deprecated
    ret.x = 0
    ret.y = 0
    ret.width  = args.width
    ret.height = args.height
    ret._border_width = 0
    ret.ontop = false
    ret.below = false
    ret.above = false
    ret.margin = args.margin or {}
    ret.anchor = args.anchor or 0
    ret.exclusive = args.exclusive or 0
    ret.layer = args.layer or
        (args.ontop and wau.zwlr_layer_shell_v1.Layer.OVERLAY) or
        (args.below and wau.zwlr_layer_shell_v1.Layer.BOTTOM) or
        wau.zwlr_layer_shell_v1.Layer.TOP

    for k, v in pairs(args) do
        ret[k] = v
    end

    ret.geometry = function(_, _)
        -- TODO: new size?
        return {
            x = ret.x,
            y = ret.y,
            width  = ret.width,
            height = ret.height
        }
    end

    ret._private = {}
    ret._private._struts = { top = 0, right = 0, left = 0, bottom = 0 }

    for _, k in pairs{ "_buttons", "get_xproperty", "set_xproperty" } do
        ret[k] = function(...) print(k, ...) end
    end

    ret.drawable = drawable {
        width = ret.width,
        height = ret.height
    }
    ret.drawable.geometry = ret.geometry

    local mywidget = con.layershell:get_layer_surface(ret.drawable.wl_surface, con.output,
        wau.zwlr_layer_shell_v1.Layer.TOP, "epicwau")

    mywidget:set_anchor(ret.anchor)
            :set_layer(ret.layer)
            :set_exclusive_zone(ret.exclusive)
            :set_margin(ret.margin.top or 0, ret.margin.bottom or 0,
                        ret.margin.right or 0, ret.margin.left or 0)
            :set_size(ret.width, ret.height)
            :add_listener { ["configure"] = wau.zwlr_layer_surface_v1.ack_configure }

    ret.drawable.wl_surface:commit()
    con.display:roundtrip()


    function ret:struts(new)
        print("struts")
        for k, v in pairs(new or {}) do
            ret._private._struts[k] = v
        end

        return ret._private._struts
    end

    local md = setmetatable(ret, {
                        __index     = function(...) return meta.__index(...) end,
                        __newindex = function(...) return meta.__newindex(...) end
                    })

    table.insert(drawins, md)

    return md
end

function drawin.get()
    return drawins
end

return setmetatable(drawin, { __call = new_drawin })

