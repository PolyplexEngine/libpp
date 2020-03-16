module polyplex.core.game;

import polyplex.utils.logging;

import polyplex.math;
import polyplex.core.windows;
import polyplex.core.render;
import polyplex.core.input;
import polyplex.core.events;
import polyplex.core.content;
import polyplex.core.audio;
import polyplex.core.time;
static import win = polyplex.core.window;

import polyplex.utils.strutils;
import polyplex : InitLibraries, UnInitLibraries;

import bindbc.sdl;
import events;

import std.math;
import std.random;
import std.typecons;
import std.stdio;
import std.conv;

import core.memory;

/**
	The base system to manage a game
	This class handles the following:
	 * Spawning a GameWindow
	 * Starting an event loop for input
	 * Creating an audio subsystem
	 * Fixed timestep updates
	 * Content management pipeline creation

	Basicly, extend this class to create a game.
*/
abstract class Game {
private:
	GameEventSystem events;
	GameTime times;
	ulong frameTimeStart = 0;
	double frameTimeDelta = 0;
	ulong frameTimeLast = 0;
	bool enableAudio = true;

	double lag = 0.0;
	double msTarget = 0.250;

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

public:

	/**
		Run a fixed time step update
	*/
	void FixedUpdate(double fixedDelta) { }

	// Abstract declarations
	abstract {
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

final:
	/// Event raised when the window changes its size
	Event!GameResizeEventArgs OnWindowSizeChanged = new Event!GameResizeEventArgs;

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
		return msTarget;
	}

	/// Returns true if the game is running slowly
	@property bool IsGameLagging() {
		return lag > 10.0;
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
		times.updateTotal(cast(double)SDL_GetTicks());

		//Update events.
		if (events !is null) {
			PPEvents.PumpEvents();

			//Do actual updating and drawing.
			events.Update();
		}

		// Run user set update and draw functions
		Update(times);
		
		lag += frameTimeDelta;
		while (lag >= msTarget) {

			FixedUpdate(msTarget);
			lag -= msTarget;
		}
		if (lag < 0) lag = 0;
		
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

			events.OnWindowSizeChanged ~= (void* sender, GameResizeEventArgs data) {
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
	}
}

