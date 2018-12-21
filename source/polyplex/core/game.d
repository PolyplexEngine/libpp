module polyplex.core.game;

import polyplex.math;
static import win = polyplex.core.window;
import polyplex.core.windows;
import polyplex.core.render;
import polyplex.core.input;
import polyplex.core.events;
import polyplex.core.content;
import polyplex.core.audio;
import polyplex.utils.logging;

import polyplex.utils.strutils;

import bindbc.sdl;
import sev.event;

import std.math;
import std.random;
import std.typecons;
import std.stdio;
import std.conv;

import core.memory;

public class GameTime {
	private ulong ticks;

	public @property ulong BaseValue() { return ticks; }
	public @property void BaseValue(ulong ticks) { this.ticks = ticks; }

	public @property ulong LMilliseconds() { return ticks; }
	public @property ulong LSeconds() { return LMilliseconds/1000; }
	public @property ulong LMinutes() { return LSeconds/60; }
	public @property ulong LHours() { return LMinutes/60; }

	public @property double Milliseconds() { return cast(double)ticks; }
	public @property double Seconds() { return Milliseconds/1000; }
	public @property double Minutes() { return Seconds/60; }
	public @property double Hours() { return Minutes/60; }

	public static GameTime FromSeconds(ulong seconds) {
		return new GameTime(seconds*1000);
	}

	public static GameTime FromMinutes(ulong minutes) {
		return FromSeconds(minutes*60);
	}

	public static GameTime FromHours(ulong hours) {
		return FromMinutes(hours*60);
	}

	public GameTime opBinary(string op:"+")(GameTime other) {
		return new GameTime(this.ticks+other.ticks);
	}

	public GameTime opBinary(string op:"-")(GameTime other) {
		return new GameTime(this.ticks-other.ticks);
	}

	public GameTime opBinary(string op:"/")(GameTime other) {
		return new GameTime(this.ticks/other.ticks);
	}

	public GameTime opBinary(string op:"*")(GameTime other) {
		return new GameTime(this.ticks*other.ticks);
	}

	public float PercentageOf(GameTime other) {
		return cast(float)this.ticks/cast(float)other.ticks;
	}

	public string ToString() {
		return LHours.text ~ ":" ~ (LMinutes%60).text ~ ":" ~ (LSeconds%60).text ~ "." ~ (LMilliseconds%60).text;
	}

	public string FormatTime(string formatstring) {
		return Format(formatstring, LHours, LMinutes%60, LSeconds%60, LMilliseconds%60);
	}

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
	private win.Window window;
	private GameEventSystem events;
	private GameTimes times;
	private static uint MAX_SAMPLES = 100;
	private long[] samples;
	private ulong start_frames = 0;
	private ulong delta_frames = 0;
	private ulong last_frames = 0;
	private double avg_fps = 0;
	private bool enable_audio = true;

	protected ContentManager Content;
	protected SpriteBatch sprite_batch;

	/// Wether the engine should count FPS and frametimes.
	public bool CountFPS = false;

	public Event OnWindowSizeChanged = new Event();
	public @property GameTime TotalTime() { return times.TotalTime; }
	public @property GameTime DeltaTime() { return times.DeltaTime; }

	public @property bool ShowCursor() {
		return (SDL_ShowCursor(SDL_QUERY) == SDL_ENABLE);
	}

	public @property void ShowCursor(bool value) {
		SDL_ShowCursor(cast(int)value);
	}

	public @property bool AudioEnabled() {
		return !(DefaultAudioDevice is null);
	}

	public @property void AudioEnabled(bool val) {
		enable_audio = val;
		if (val == true) DefaultAudioDevice = new AudioDevice();
		else DefaultAudioDevice = null;
	}

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

	public @property win.Window Window() { return window; }

	this(bool audio = true) {
		enable_audio = audio;
	}

	~this() {
		UnloadContent();
		destroy(window);
	}

	public void Run() {
		import polyplex;
		InitLibraries();
		
		events = new GameEventSystem();

		if (window is null) {
			window = new SDLGameWindow(new Rectangle(0, 0, 0, 0), false);
		}
		window.Show();
		InitLibraries();

		import polyplex.core.audio.music;
		
		do_update();
		
		UnInitLibraries();
	}

    private void do_update() {
		//Preupdate before init, just in case some event functions are use there.
		events.Update();

		//Wait for window to open.
		Logger.Debug("~~~ Init ~~~");
		while (!window.Visible) {}

		//Update window info.
		window.UpdateState();
		events.OnExitRequested ~= (void* sender, EventArgs data) {
			window.Close();
		};

		events.OnWindowSizeChanged ~= (void* sender, EventArgs data) {
			window.UpdateState();
			Renderer.AdjustViewport();
			OnWindowSizeChanged(sender, data);
		};
		
		times = new GameTimes(new GameTime(0), new GameTime(0));
		int avg_c = 0;

		// Init sprite batch
		this.sprite_batch = Renderer.NewBatcher();
		this.Content = new ContentManager();

		if (enable_audio) DefaultAudioDevice = new AudioDevice();
		
		Init();
		LoadContent();
		Logger.Debug("~~~ Gameloop ~~~");
		while (window.Visible) {
			//FPS begin counting.
			start_frames = SDL_GetTicks();
			times.TotalTime.BaseValue = start_frames;

			//Update events.
			PPEvents.PumpEvents();

			//Do actual updating and drawing.
			events.Update();
			Update(times);
			Draw(times);

			// Exit the game if the window is closed.
			if (!window.Visible) break;

			//Swap buffers and chain.
			if (sprite_batch !is null) sprite_batch.SwapChain();
			Renderer.SwapBuffers();

			if (CountFPS) {
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
		}
		import polyplex.core.audio.music;
		shouldStop = true;

		Logger.Info("Cleaning up music threads... {0}", openMusicChannels);
		while (openMusicChannels > 0) {}

		Logger.Info("Cleaning up resources...");
		UnloadContent();

		destroy(DefaultAudioDevice);
		destroy(window);

		GC.collect();

		Logger.Success("Cleanup completed...");

		Logger.Success("~~~ GAME ENDED ~~~");
	}

	public void Quit() {
		this.window.Close();
	}

	public abstract void Init();
	public abstract void LoadContent();
	public abstract void UnloadContent();
	public abstract void Update(GameTimes game_time);
	public abstract void Draw(GameTimes game_time);
}

