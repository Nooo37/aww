local path = ...
return function()
    awesome      = require( path .. ".awesome"      )
    root         = require( path .. ".root"         )
    tag          = require( path .. ".tag"          )
    screen       = require( path .. ".screen"       )
    client       = require( path .. ".client"       )
    mouse        = require( path .. ".mouse"        )
    button       = require( path .. ".button"       )
    keygrabber   = require( path .. ".keygrabber"   )
    mousegrabber = require( path .. ".mousegrabber" )
    dbus         = require( path .. ".dbus"         )
    key          = require( path .. ".key"          )
end
