[![Polyplex Logo][logo]](http://git.pplex.org/Polyplex/ppbranding)

# Polyplex Main Library (libpp)
<a href="https://www.patreon.com/bePatron?u=10156994" data-patreon-widget-type="become-patron-button"><img class="s5qsvfm-0 fIpNGV" src="https://c5.patreon.com/external/logo/become_a_patron_button.png"></a></img> <a href='https://ko-fi.com/O4O59UGN' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi2.png?v=0' border='0' alt='Buy Clipsey a Coffee at ko-fi.com' /></a> [Join the Discord Server](https://discord.gg/Dus5ArV)

libpp is an XNA like framework written in D. libpp supports OpenGL and will in the future support Vulkan.

The framework is written to be easy to read and understand for people comming from an C#/XNA background.

libpp is the base rendering, input handling, content handling, etc. library for the WIP Polyplex engine.

### Top Tier Patrons
* The Linux Gamer Community

## Using libpp
Find libpp on the [dub database](https://code.dlang.org/packages/pp) for instructions on adding libpp as a dependency to your dub project.

Once added, you will need to set logging levels, choose a backend and create a window.

### Current capabilities
Polyplex is still very early in development, but libpp can already be used to make simple 2D games, that are relatively easy to port to other platforms.
Polyplex packages textures, sounds, etc. into files with the extension ppc. To convert ogg, png, jpeg or tga files to .ppc, use [ppcc](https://git.pplex.org/Polyplex/ppcc)


### Examples
## PPCC
`ppcc -c (or --convert) my_file.(extension)` output will be put in `my_file.ppc`.

From libpp it can be accessed via `ContentManager.Load<Type>("my_file")`

## libpp
Example of simple polyplex application:
```d
// Most of this is being restructured, old example is obsolete, a new one will be here soon :)
```

You can also check out [example_game](http://git.pplex.org/Polyplex/example_game), which is used as a testbed for new libpp features/fixes.

## Notice
##### The library is written in what would be considered non-idiomatic D.

[logo]: https://git.pplex.org/Polyplex/ppbranding/raw/commit/419d73673a9fde5a66554b19155b43dd13d04514/flat/libpp-pngs/libpp_transparent@256w.png
