module polyplex.core.game;

import polyplex.math;
import polyplex.core.window;
import polyplex.core.render;
import polyplex.core.input;
import polyplex.core.events;
import polyplex.core.content;
import polyplex.utils.logging;

import derelict.sdl2.sdl;
import sev.event;

import  std.math,
        std.random,
        std.typecons;
import std.stdio;

public class GameTime {
	private ulong ticks;

	public @property ulong BaseValue() { return ticks; }
	public @property void BaseValue(ulong ticks) { this.ticks = ticks; }

	public @property ulong LMilliseconds() { return ticks; }
	public @property ulong LSeconds() { return LMilliseconds/60; }
	public @property ulong LMinutes() { return LSeconds/60; }
	public @property ulong LHours() { return LMinutes/60; }

	public @property double Milliseconds() { return cast(double)ticks; }
	public @property double Seconds() { return Milliseconds/60; }
	public @property double Minutes() { return Seconds/60; }
	public @property double Hours() { return Minutes/60; }

	this(ulong ticks) {
		this.ticks = ticks;
	}
}

public class GameTimes {

	this(GameTime total, GameTime delta) {
		TotalTime = total;
		DeltaTime = delta;
	}

	public GameTime TotalTime;
	public GameTime DeltaTime;
}

public abstract class Game {
	//Private properties
	private GameWindow window;
	private GameEventSystem events;
	private GameTimes times;
	private static uint MAX_SAMPLES = 100;
	private long[] samples;
	private ulong start_frames = 0;
	private ulong delta_frames = 0;
	private ulong last_frames = 0;
	private double avg_fps = 0;

	protected ContentManager Content;

	public Event OnWindowSizeChanged = new Event();
	public @property GameTime TotalTime() { return times.TotalTime; }
	public @property GameTime DeltaTime() { return times.DeltaTime; }

	public @property float FPS() {
		if (delta_frames != 0) {
			return 1000/delta_frames;
		}
		return 0f;
	}

	public @property int AverageFPS() {
		if (avg_fps != 0) {
			return cast(int)(1000/cast(double)avg_fps);
		}
		return 0;
	}

	public @property float Frametime() {
		return delta_frames;
	}

	public @property GameWindow Window() { return window; }
	public @property Renderer Drawing() { return window.Drawing; }

	public @property SpriteBatch sprite_batch() { return window.Drawing.Batch; }

	this(string title, Rectangle bounds) {
		window = new GameWindow(title, bounds);
		events = new GameEventSystem();
	}
	 
	this(Rectangle bounds) {
		window = new GameWindow(bounds);
		events = new GameEventSystem();
	}

	this() {
		window = new GameWindow();
		events = new GameEventSystem();
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

		//Wait for window to open.
		Logger.Debug("~~~ Init ~~~");
		while (!window.Visible) {}

		//Update window info.
		window.UpdateInfo();
		events.OnExitRequested += (void* sender, EventArgs data) {
			window.Close(); 
		};

		events.OnWindowSizeChanged += (void* sender, EventArgs data) {
			window.UpdateInfo();
			window.Drawing.AdjustViewport();
			OnWindowSizeChanged(sender, data);
		};
		
		times = new GameTimes(new GameTime(0), new GameTime(0));
		int avg_c = 0;

		this.Content = new PPCContentManager();

		Init();

		LoadContent();
		Logger.Debug("~~~ Gameloop ~~~");
		while (window.Visible) {
			//FPS begin counting.
			start_frames = SDL_GetTicks();
			times.TotalTime.BaseValue = start_frames;

			//Do actual updating and drawing.
			events.Update();
			Update(times);
			Draw(times);

			//Swap buffers.
			window.SwapBuffers();

			//FPS counter.
			delta_frames = SDL_GetTicks() - start_frames;
			times.DeltaTime.BaseValue = delta_frames;
			last_frames = start_frames;

			if (samples.length <= MAX_SAMPLES) {
				samples.length++;
			} else {
				samples[0] = -1;
				for (int i = 1; i < samples.length; i++) {
					if (samples[i-1] == -1) {
						samples[i-1] = samples[i];
						samples[i] = -1;
					}
				}
				samples[samples.length-1] = cast(long)delta_frames;
			}
			double t = 0;
			foreach(ulong sample; samples) {
				t += cast(double)sample;
			}
			t /= MAX_SAMPLES;
			avg_fps = t;
		}
		Logger.Success("~~~ GAME ENDED ~~~\nHave a nice day! c:");
    }

	public void Quit() {
		this.window.Close();
	}

	public abstract void Init();
	public abstract void LoadContent();
	public abstract void Update(GameTimes game_time);
	public abstract void Draw(GameTimes game_time);
}

