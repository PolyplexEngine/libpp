[![Polyplex Logo][logo]](https://github.com/PolyplexEngine/branding)

# Polyplex Main Library (libpp)
[Mastodon](https://mastodon.social/@Polyplex) | [Twitter](https://twitter.com/polyplexengine)

[Join the Discord Server](https://discord.gg/Dus5ArV)


libpp is an game development framework written in D, supporting OpenGL 3.3 (and above). 

_OpenGL ES 2 and Vulkan will be supported in the future._

libpp is the base rendering, input handling, content handling, etc. library for the WIP Polyplex engine.

### Top Tier Patrons
Previously a patreon was up for this project, that's no longer the case.
Here's the people who contributed the highest tier at the time
* The Linux Gamer Community
* WeimTime

## Using libpp
Find libpp on the [dub database](https://code.dlang.org/packages/pp) for instructions on adding libpp as a dependency to your dub project.

Once added, you will need to set logging levels, choose a backend and create a window.

### Current capabilities
Polyplex is still very early in development, but libpp can already be used to make simple 2D games, that are relatively easy to port to other platforms.
Polyplex packages textures, sounds, etc. into files with the extension ppc. To convert ogg, png, jpeg or tga files to .ppc, use [ppcc](https://github.com/PolyplexEngine/ppcc)

Othewise, you can use `Content.Load!(Type)(string);` by prepending `!` to the path (based on content directory) to the raw file.


### Examples
## PPCC
`ppcc -c (or --convert) my_file.(extension)` output will be put in `my_file.ppc`.

From libpp it can be accessed via `ContentManager.Load!Type("my_file")`

## libpp
Example of simple polyplex application:
```d
module example;
import std.stdio;
import polyplex;
import polyplex.math;

void main(string[] args)
{
	arg = args[1..$];

	// Enable info and debug logs.
	LogLevel |= LogType.Info;
	LogLevel |= LogType.Debug;

	// Create game instance and start game.
	MyGame game = new MyGame();
	game.Run();
}

class MyGame : Game
{
	Texture2D myTexture;
	this() {

	}

	public override void Init()
	{
		// Enable/Disable VSync.
		Window.VSync = VSyncState.VSync;
	}

	public override void LoadContent() {
		// Load textures, sound, shaders, etc. here

		//Example:
		myTexture = Content.Load!Texture2D("myTexture");
	}	

	public override void Update(GameTimes game_time)
	{
		
	}

	public override void Draw(GameTimes game_time)
	{
		Renderer.ClearColor(Color.CornflowerBlue);
	}
}

```

You can also check out [example_game](http://github.com/PolyplexEngine/example_game), which is used as a testbed for new libpp features/fixes.

## Notice
This framework will **not** work officially on macOS, in future updates support code will be fully removed. The reason for this is that Apple has deprecated OpenGL, Polyplex will not support Metal, in any form (including MoltenVK) in the near-to-far future.

##### The library is written in what would be considered non-idiomatic D.

[logo]: https://raw.githubusercontent.com/PolyplexEngine/branding/master/flat/libpp-pngs/libpp_transparent%40256w.png
