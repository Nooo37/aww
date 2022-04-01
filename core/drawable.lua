local gears_obj = require("gears.object")
local helpers = require("helpers")
local con = require("con")

local drawable, meta = awesome._shim_fake_class()
drawable = setmetatable({}, {__mode="v"})
local lgi = require("lgi")
local cairo = lgi.cairo

local function new_drawable(_, args)
    assert(args.width and args.height, "Drawable needs width and height")
    local ret = gears_obj()
    ret.width = args.width
    ret.height = args.height
    ret.stride = 4 * ret.width
    ret.size = ret.stride * ret.height
    ret.fd, ret.data = helpers.allocate_shm(ret.size)

    ret.valid    = true
    ret.surface  = cairo.ImageSurface.create_for_data(ret.data,
        cairo.Format.ARGB32, ret.width, ret.height, ret.stride)

    ret.geometry = function(_, _)
        -- TODO: new size?
        return {
            x      = 0,
            y      = 0,
            width  = ret.width,
            height = ret.height
        }
    end

    ret.refresh  = function(self)
        local mypool = con.shm:create_pool(self.fd, self.size)
        self.buffer = mypool:create_buffer(0, self.width, self.height, self.stride, 0)
        self.wl_surface:attach(self.buffer, 0, 0)
                       :commit()
                       :damage(0, 0, self.width, self.height)
        con.display:roundtrip()
    end

    ret.draw = function(_)
        -- TODO: what to do here?
    end

    ret.wl_surface = con.compositor:create_surface()

    return ret
end

return setmetatable(drawable, { __call = new_drawable })

