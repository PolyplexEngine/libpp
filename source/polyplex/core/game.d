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
import polyplex : InitLibraries, UnInitLibraries;

import bindbc.sdl;
import sev.event;

import std.math;
import std.random;
import std.typecons;
import std.stdio;
import std.conv;

import core.memory;

class GameTimeSpan {
	private double ticks;

	public @property double BaseValue() { return ticks; }
	public @property void BaseValue(double ticks) { this.ticks = ticks; }

	public @property ulong LMilliseconds() { return cast(ulong)(ticks*1000); }
	public @property ulong LSeconds() { return cast(ulong)ticks; }
	public @property ulong LMinutes() { return LSeconds/60; }
	public @property ulong LHours() { return LMinutes/60; }

	public @property double Milliseconds() { return ticks*1000; }
	public @property double Seconds() { return ticks; }
	public @property double Minutes() { return Seconds/60; }
	public @property double Hours() { return Minutes/60; }

	public static GameTimeSpan FromSeconds(ulong seconds) {
		return new GameTimeSpan(seconds*1000);
	}

	public static GameTimeSpan FromMinutes(ulong minutes) {
		return FromSeconds(minutes*60);
	}

	public static GameTimeSpan FromHours(ulong hours) {
		return FromMinutes(hours*60);
	}

	public GameTimeSpan opBinary(string op:"+")(GameTimeSpan other) {
		return new GameTimeSpan(this.ticks+other.ticks);
	}

	public GameTimeSpan opBinary(string op:"-")(GameTimeSpan other) {
		return new GameTimeSpan(this.ticks-other.ticks);
	}

	public GameTimeSpan opBinary(string op:"/")(GameTimeSpan other) {
		return new GameTimeSpan(this.ticks/other.ticks);
	}

	public GameTimeSpan opBinary(string op:"*")(GameTimeSpan other) {
		return new GameTimeSpan(this.ticks*other.ticks);
	}

	public float PercentageOf(GameTimeSpan other) {
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

class GameTime {
public:
	this(GameTimeSpan total, GameTimeSpan delta) {
		TotalTime = total;
		DeltaTime = delta;
	}

	/**
		The total time the game has been running
	*/
	GameTimeSpan TotalTime;

	/**
		The time between this and the last frame
	*/
	GameTimeSpan DeltaTime;

private:
	void updateDelta(double delta) {
		DeltaTime.BaseValue = delta;
	}
	
	void updateTotal(double total) {
		TotalTime.BaseValue = total;
	}
}

abstract class Game {
private:
	GameEventSystem events;
	GameTime times;
	ulong frameTimeStart = 0;
	double frameTimeDelta = 0;
	ulong frameTimeLast = 0;
	bool enableAudio = true;

	double fixedft;
	double accumulator = 0.0;
	double targetStep = 60;
	double dt() {
		return 1/targetStep;
	}

    void doUpdate() {
		Prepare();
		while (!RunOne()) {
		}
	}

protected:
	//Private properties
	win.Window window;
	ContentManager Content;
	SpriteBatch spriteBatch;

package:
	void forceWindowChange(win.Window newWindow) {
		this.window = newWindow;
	}


public abstract {
	/**
		Initialize core game variables and the like.
		
		Content can be loaded in LoadContent.
	*/
	void Init();
	/**
		Load game assets from disk, etc.
	*/
	void LoadContent();

	/**
		Unload game assets, etc.

		Use D's `destroy(<*>);` function to unload content
	*/
	void UnloadContent();

	/**
		Run an update iteration
	*/
	void Update(GameTime gameTime);

	/**
		Run a draw iteration
	*/
	void Draw(GameTime gameTime);
}

public:

	/**
		Run a fixed time step update
	*/
	void FixedUpdate(double fixedDelta) { }

public final:
	/// Wether the engine should count FPS and frametimes.
	bool CountFPS = false;

	Event OnWindowSizeChanged = new Event();

	/// How much time since game started
	@property GameTimeSpan TotalTime() { return times.TotalTime; }

	/// How much time since last frame
	@property GameTimeSpan DeltaTime() { return times.DeltaTime; }

	/// Wether the system cursor should be shown while inside the game window.
	@property bool ShowCursor() {
		return (SDL_ShowCursor(SDL_QUERY) == SDL_ENABLE);
	}

	/// ditto.
	@property void ShowCursor(bool value) {
		SDL_ShowCursor(cast(int)value);
	}

	/// Wether the audio backend is enabled.
	@property bool AudioEnabled() {
		return !(DefaultAudioDevice is null);
	}

	/// ditto.
	@property void AudioEnabled(bool val) {
		enableAudio = val;
		if (val == true) DefaultAudioDevice = new AudioDevice();
		else DefaultAudioDevice = null;
	}

	/// How many miliseconds since the last frame was drawn
	@property double Frametime() {
		return frameTimeDelta;
	}

	/// How many miliseconds since the last frame was drawn
	@property double FixedFrametime() {
		return fixedft;
	}

	/// The window the game is being rendered to
	@property win.Window Window() { return window; }

	/**
		Create a new game instance.
	*/
	this(bool audio = true, bool eventSystem = true) {
		enableAudio = audio;
		if (eventSystem) events = new GameEventSystem();
	}

	~this() {
		UnloadContent();
		destroy(window);
	}

	/**
		Start/run the game
	*/
	void Run() {
		if (window is null) {
			window = new SDLGameWindow(Rectanglei(0, 0, 0, 0), false);
		}
		InitLibraries();
		window.Show();
		Renderer.setWindow(window);
		Renderer.Init();
		
		doUpdate();
		UnInitLibraries();
	}

	/**
		Poll system events
	*/
	void PollEvents() {
		events.Update();
	}

	
	/**
		Run a single frame of the game
	*/
	bool RunOne() {
		//FPS begin counting.
		frameTimeStart = SDL_GetPerformanceCounter();
		times.updateTotal(cast(double)(SDL_GetTicks()/1000));

		//Update events.
		if (events !is null) {
			PPEvents.PumpEvents();

			//Do actual updating and drawing.
			events.Update();
		}
		
		fixedft = frameTimeDelta > 0.25 ? 0.25 : frameTimeDelta;
		accumulator += fixedft;

		while (accumulator >= dt) {
			FixedUpdate(dt);
			accumulator -= dt;
		}

		// Run user set update and draw functions
		Update(times);
		Draw(times);

		// Exit the game if the window is closed.
		if (!window.Visible) {
			Quit();
			return true;
		}

		//Swap buffers and chain.
		if (spriteBatch !is null) spriteBatch.SwapChain();
		Renderer.SwapBuffers();

		// Update frametime delta
		frameTimeDelta = cast(double)((SDL_GetPerformanceCounter() - frameTimeStart) * 1000) / cast(double)SDL_GetPerformanceFrequency();
		times.updateDelta(frameTimeDelta);
		frameTimeLast = frameTimeStart;
		return false;
	}


	/**
		Prepare the backend for use.
	*/
	void Prepare(bool waitForVisible = true) {
		// Preupdate before init, just in case some event functions are use there.
		if (events !is null) events.Update();

		//Wait for window to open.
		Logger.Debug("~~~ Init ~~~");
		while (waitForVisible && !window.Visible) {}

		//Update window info.
		window.UpdateState();
		if (events !is null) {
			events.OnExitRequested ~= (void* sender, EventArgs data) {
				window.Close();
			};

			events.OnWindowSizeChanged ~= (void* sender, EventArgs data) {
				window.UpdateState();
				Renderer.AdjustViewport();
				OnWindowSizeChanged(sender, data);
			};
		}
		
		times = new GameTime(new GameTimeSpan(0), new GameTimeSpan(0));

		// Init sprite batch
		this.spriteBatch = new SpriteBatch();
		this.Content = new ContentManager();

		if (enableAudio) DefaultAudioDevice = new AudioDevice();
		
		Init();
		LoadContent();
		Logger.Debug("~~~ Gameloop ~~~");
	}
	
	/**
		Quits the game
	*/
	void Quit() {
		import polyplex.core.audio.music;


		// Stop music thread(s) and wait...
		stopMusicThread();

		Logger.Info("Cleaning up resources...");
		UnloadContent();

		destroy(DefaultAudioDevice);
		destroy(window);

		GC.collect();

		Logger.Success("Cleanup completed...");

		Logger.Success("~~~ GAME ENDED ~~~");
		this.window.Close();
	}
}

