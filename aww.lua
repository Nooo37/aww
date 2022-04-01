local wau = require("wau")
local lgi = require("lgi")
local GLib = lgi.GLib

local config = {
    path = ";/usr/share/awesome/lib/?/init.lua;/usr/share/awesome/lib/?.lua",
    timeout = 20,
}
package.path = package.path .. config.path

local shims = require("shims")
shims()

local core = require("core")
core()

-- Force luacheck to be silent about setting those as unused globals
assert(awesome and root and tag and screen and client and mouse)

-- Silence debug warnings
require("gears.debug").print_warning = function() end

-- Revert the background widget to something compatible with Cairo SVG
local bg = require("wibox.container.background")
bg._use_fallback_algorithm()

require("awful._compat")

local con = require("con")
con.init()

local wibox = require("wibox")
wibox.Anchor = wau.zwlr_layer_surface_v1.Anchor

if not arg[1] then error("provide input file") end

local success, mes = pcall(dofile, arg[1])

if not success then error(mes) end

local gtimer = require("gears.timer")

GLib.timeout_add(GLib.PRIORITY_DEFAULT, config.timeout, function()
    con.display:roundtrip()
    gtimer.run_delayed_calls_now()
    return true
end)

local mainloop = GLib.MainLoop(nil, nil)
mainloop:run()

