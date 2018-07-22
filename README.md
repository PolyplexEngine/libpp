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
import polyplex;
import polyplex.math;
import polyplex.core;
import std.conv;

void main(string[] args) {
  // Show info logs.
  LogLevel |= LogType.Info;
  
  // libpp now has a simple game launcher
  // It will automatically choose the graphics API most suitable.
  BasicGameLauncher.InitSDL();
  
  //When using the ~master build, use --opengl since vulkan support is not done yet.
  BasicGameLauncher.LaunchGame(new Game1(), ["--opengl"] ~ args);
}

class Game1 : Game {
  Texture2D my_texture;

  // Constructor
  this() {
    WindowInfo inf = new WindowInfo();
    inf.Name = "Game1";
    inf.Bounds = new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 1080, 1024);
    super(inf);
  }
  
  //Init is run before the game loop starts.
  public override void Init() {
    // Set the content root to content/
    Content.ContentRoot = "content/";
  }

  // LoadContent is a method you can load content in, exists to split up init and content loading for more readability.
  public override void LoadContent() {
    my_texture = this.Content.LoadTexture("my_texture");
  }
  
  //Update is run before draw in the game loop.
  public override void Update(GameTimes game_time) {
    // Quit game if Q is pressed.
    if (Keyboard.GetState().IsKeyDown(Keys.Q)) this.Quit();
    
    //FPS counter as window title.
    Window.Title = "FPS: " ~ to!string(AverageFPS);
  }
  
  //Draw is run after the logic update of the game loop.
  public override void Draw(GameTimes game_time) {
  
    //Clears color, generally put first in the Draw method.
    Drawing.ClearColor(Color.Black);
    
    sprite_batch.Begin();
    sprite_batch.Draw(my_texture, new Rectangle(0, 0, 32, 32), texture.Size, Color.White);
    sprite_batch.End();
  }
}
```

You can also check out [example_game](http://git.pplex.org/Polyplex/example_game), which is used as a testbed for new libpp features/fixes.

## Notice
##### The library is written in what would be considered non-idiomatic D.

[logo]: https://git.pplex.org/Polyplex/ppbranding/raw/commit/419d73673a9fde5a66554b19155b43dd13d04514/flat/libpp-pngs/libpp_transparent@256w.png
