local wau = require("wau")
wau:require("protocol.xdg-shell") -- layershell implicitly depends on xdg-shell
wau:require("protocol.wlr-layer-shell-unstable-v1")

local M = {}

function M.init()
    M.display = wau.wl_display.connect(nil)
    assert(M.display, "Couldn't connect to the wayland server")
    local registry = M.display:get_registry()
    registry:add_listener {
        ["global"] = function(self, name, interface, version)
            if interface == "wl_output" then
                M.output = self:bind(name, wau.wl_output, version)
            elseif interface == "wl_compositor" then
                M.compositor = self:bind(name, wau.wl_compositor, version)
            elseif interface == "wl_shm" then
                M.shm = self:bind(name, wau.wl_shm, version)
            elseif interface == "zwlr_layer_shell_v1" then
                M.layershell = self:bind(name, wau.zwlr_layer_shell_v1, version)
            end
        end
    }
    M.display:roundtrip()
    assert(M.output and M.compositor and M.shm, "Couldn't load wl_ output, compositor or shm")
    assert(M.layershell, "Couldn't load layershell")
end

return M
