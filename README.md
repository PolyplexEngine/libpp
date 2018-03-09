[![Polyplex Logo][logo]](https://github.com/PolyplexEngine/ppbranding)

# Polyplex Main Library (libpp)
<a href='https://ko-fi.com/O4O59UGN' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi2.png?v=0' border='0' alt='Buy Clipsey a Coffee at ko-fi.com' /></a>

[Join the Discord Server](https://discord.gg/Dus5ArV)

Polyplex is an XNA like framework and engine written in D. Polyplex supports OpenGL and will in the future support Vulkan.

The framework is written to be easy to read and understand for people comming from an C#/XNA background.

## Using libpp
Find libpp on the [dub database](https://code.dlang.org/packages/pp) for instructions on adding libpp as a dependency to your dub project.

Once added, you will need to set logging levels, choose a backend and create a window.

### Current capabilities
Polyplex is still very early in development, but libpp can already be used to make simple 2D games, that are relatively easy to port to other platforms.

### Examples
Example of simple polyplex application:
```d
import polyplex;
import polyplex.math;
import polyplex.core.window;
import polyplex.core.input;
import polyplex.core.game;
import polyplex.core.color;
import polyplex.core.render;
import polyplex.core.content;
import std.conv;

void main(string[] args) {
  // Show info logs.
  LogLevel |= LogType.Info;
  
  // Select Open GL as a graphics backend.
  // Changing the property and rerunning InitLibraries will:
  // 1. unload the previous graphics backend library from memory
  // 2. bind the new prefered graphics backend.
  ChosenBackend = GraphicsBackend.OpenGL;
  InitLibraries();
  Game my_game = new Game1();
  my_game.Run();
}

class Game1 : Game {
  // Constructor
  this() {
    WindowInfo inf = new WindowInfo();
    inf.Name = "Game1";
    inf.Bounds = new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 1080, 1024);
    super(inf);
  }
  
  //Init is run before the game loop starts.
  public override void Init() {
    //Content manager that loads raw files instead of bundles (only form supported right now)
    this.Content = new RawContentManager();
  }
  
  //Update is run before draw in the game loop.
  public override void Update(GameTimes game_time) {
    // Quit game if Q is pressed.
    if (Input.IsKeyDown(KeyCode.Q)) this.Quit();
    
    //FPS counter as window title.
    Window.Title = "FPS: " ~ to!string(AverageFPS);
  }
  
  //Draw is run after the logic update of the game loop.
  public override void Draw(GameTimes game_time) {
  
    //Clears color, generally put first in the Draw method.
    Drawing.ClearColor(Colors.Black);
  }
}
```

You can also check out [example_game](https://github.com/PolyplexEngine/example_game), which is used as a testbed for new libpp features/fixes.

## Notice
libpp uses a modified version of [gl3n](https://github.com/Dav1dde/gl3n) made to fit the code-style of libpp. Seen in the `polyplex.math` package.

##### Notice, the library is written in what would be considered non-idiomatic D.
##### A styleguide will be drafted at some point and the code will be cleaned up once it's in a more functional state.

[logo]: https://github.com/PolyplexEngine/ppbranding/blob/master/polyplex3.jpg
