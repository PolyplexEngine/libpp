module polyplex.core.game;

import polyplex.math;
import polyplex.core.window;
import polyplex.core.render;
import polyplex.core.input;
import polyplex.core.events;
import derelict.sdl2.sdl;

import  std.math,
        std.random,
        std.typecons;
import std.stdio;

public struct GameTime {
	private ulong ticks;

	public @property ulong Milliseconds() { return ticks; }
	public @property ulong Seconds() { return ticks/60; }
	public @property ulong Minutes() { return Seconds/60; }
	public @property ulong Hours() { return Minutes/60; }

	this(ulong ticks) {
		this.ticks = ticks;
	}
}

public abstract class Game {
    //Private properties
    private GameWindow window;
	private GameEventSystem events;
	private ulong start_frames = 0;
	private ulong delta_frames = 0;
	private ulong last_frames = 0;
	private float avg_fps = 0;
	private float sh_avg_fps = 0;

	public @property GameTime* TotalTime() { return new GameTime(start_frames); }
	public @property GameTime* DeltaTime() { return new GameTime(delta_frames); }

	public @property float FPS() {
		if (delta_frames != 0) {
			return 1000/delta_frames;
		}
		return 0f;
	}

	public @property int AverageFPS() {
		return cast(int)sh_avg_fps;
	}

	protected @property GameWindow Window() { return window; }
	protected @property InputHandler Input() { return events.Input; }
	protected @property Renderer Drawing() { return window.Drawing; }

	this(WindowInfo inf) {
		window = new GameWindow(inf);
		events = new GameEventSystem(new InputHandler());
	}

	~this() {
		destroy(window);
	}

	public void Run() {
		window.Show();
		do_update();
	}

    private void do_update() {
		//Preupdate before init, just in case some event functions are use there.
		events.Update();
		writeln("~~~ Init ~~~");
		while (!window.Visible) {}
		Init();
		window.UpdateInfo();
		window.Drawing.SetViewport(Rectangle(0, 0, window.Width, window.Height));
		writeln("~~~ Gameloop ~~~");

		events.OnExitRequested += (void* sender, void* data) {
			window.Close(); 
		};

		events.OnWindowSizeChanged += (void* sender, void* data) {
			window.UpdateInfo();
			window.Drawing.SetViewport(Rectangle(0, 0, window.Width, window.Height));
		};
		
		int avg_c = 0;
		while (window.Visible) {
			start_frames = SDL_GetTicks();
			events.Update();
			Update();
			Draw();
			window.SwapBuffers();
			delta_frames = SDL_GetTicks() - start_frames;
			last_frames = SDL_GetTicks();
			avg_fps = (avg_fps+FPS);
			avg_c++;
			if (avg_c > 10) {
				sh_avg_fps = avg_fps/avg_c;
				avg_fps = 0;
				avg_c = 0;
			}
		}
		writeln("~~~ GAME ENDED ~~~\nHave a nice day! c:");
    }

	public void Quit() {
		this.window.Close();
	}

	public abstract void Init();
	public abstract void Update();
	public abstract void Draw();
}

