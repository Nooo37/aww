# aww

Using AwesomeWM widgets on wayland[^whyland] proof of concept

## Design

- A AwesomeWM `drawable` maps to a wayland surface `wl_surface` as it is just a surface on which one can draw but without any specific role or context in which the surface will occur. In AwesomeWM a `drawable` can occur as a `drawin` or as part of a titlebar. That's similar to how wayland assignes meaning to a surface through shells. It's also in both cases the object that handles input.
- A AwesomeWM `drawin` maps to a wayland layershell surface `zwlr_layer_surface_v1` as a drawin essentially wraps a drawable and giving it a purpose as a "desktop shell widget". The two relationships `drawable` to `drawin` and `wl_surface` to `zwlr_layer_surface_v1` are very analogous.

## Project structure

- In `core/` there are the currently two replacements for wayland.
- In `shims/` there are all other objects as hollow replacments which means they don't actually do anything but only exist to keep the Awesome libraries running. They are mostly taken from the test suit in AwesomeWM.
- `aww.lua` is the entry point to the program.
- `con.lua` is the singleton that contains the wayland connection and holds the different wayland globals.
- `helpers.so` is a small C-library to create the necessary shared memory buffer.

## Constraints

- AwesomeWM always defines a position by a total x and y value. That makes sense in the context of Xorg but it would be very hacky to support that on wayland.
- As long as there is no custom titlebar protocol in the wayland/wlroots ecosystem, it's impossible to supplement that aspect of AwesomeWM.
- With the foreign toplevel protocol we get some ability to move a window from a third party app but it really isn't meant to be a window management protocol. Apart from the technical constraint here, I personally only really care about the widgets anyway.

## Get it going

Make sure to have all dependencies in place: 

- The `helpers.so` uses **lua 5.3** by default so it would be easiest to go with that lua version, otherwise change the Makefile in `helpers/`.
- [**wau**](https://github.com/Nooo37/wau) is needed. You should be able to install it from the [luarocks](https://luarocks.org/modules/Nooo37/wau) (see below).
- [**AwesomeWM**s lua library](https://github.com/awesomeWM/awesome/) and **lgi** are needed. The AwesomeWM library is expected to reside in `/usr/share/awesome/lib/` otherwise change the path in `aww.lua`.


```sh
# install wau
sudo luarocks install --server=https://luarocks.org/dev wau --lua-version 5.3

# clone the repo
git clone https://github.com/Nooo37/aww
cd aww

# this will create the needed helpers.so
make -C helpers

# make sure to be in a wayland compositor and run the example
lua5.3 aww.lua example.lua
```

### Example

In `example.lua` I constructed a minimal example that works for both:

- `lua aww.lua example.lua` if you are in a wayland[^whyland] compositor
- `cat example.lua | awesome-client"` if you are using AwesomeWM (hard to get rid of again, just restart if you don't know what to do)

[^whyland]: With "wayland" or "wayland compositor" I mean all compositors that support the layershell protocol (most notable mainstream exception being GNOME).
