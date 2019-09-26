module polyplex.core.windows.sdlwindow;
import polyplex.core.window;
import polyplex;
import polyplex.utils.sdlbool;
public import polyplex.core.render;
static import polyplex;

import bindbc.sdl;
import bindbc.opengl;
import polyplex.math;
import polyplex.utils.logging;
import std.stdio;
import std.string;
import std.conv;


public enum WindowPosition {
	Center = -1,
	Undefined = 0
}

public class SDLGameWindow : Window {
	private string start_title;
    private SDL_Window* window;
	private Rectanglei startBounds;

	/*
		Gets whenever the window is visible
	*/
    public override @property bool Visible() { return (this.window !is null); }

	// Resizing
	public override @property bool AllowResizing() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & SDL_WINDOW_RESIZABLE) > 0);
	}
	public override @property void AllowResizing(bool allow) { SDL_SetWindowResizable(this.window, ToSDL(allow)); }

	// VSync
	public override @property VSyncState VSync() {
		if (ActiveBackend == GraphicsBackend.OpenGL) return cast(VSyncState)SDL_GL_GetSwapInterval();
		return VSyncState.VSync;
	}

	public override @property void VSync(VSyncState state) {
		if (ActiveBackend == GraphicsBackend.OpenGL) SDL_GL_SetSwapInterval(state);
	}

	// Borderless
	public override @property bool Borderless() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & SDL_WINDOW_BORDERLESS) > 0);
	}
	public override @property void Borderless(bool i) { SDL_SetWindowBordered(this.window, ToSDL(!i)); }

	// Title
	public override @property string Title() { return to!string(SDL_GetWindowTitle(this.window)); }
	public override @property void Title(string value) { return SDL_SetWindowTitle(this.window, value.toStringz); }

	//Brightness
	public @property float Brightness() { return SDL_GetWindowBrightness(this.window); }
	public @property void Brightness(float b) { SDL_SetWindowBrightness(this.window, b); }

	//Fullscreen
	public override @property bool Fullscreen() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & (SDL_WINDOW_FULLSCREEN | SDL_WINDOW_FULLSCREEN_DESKTOP)) > 0);
	}

	public override @property void Fullscreen(bool i) {
		if (!i) {
			//Windowed.
			SDL_SetWindowFullscreen(this.window, 0);
			return;
		}
		if (Borderless) {
			//Fullscreen Borderless
			SDL_SetWindowFullscreen(this.window, SDL_WINDOW_FULLSCREEN_DESKTOP);
			return;
		}
		//Fullscreen
		SDL_SetWindowFullscreen(this.window, SDL_WINDOW_FULLSCREEN);
	}

	/**
		Returns the position of the window.
	*/
	public @property Vector2 Position() {
		return Vector2(ClientBounds.X, ClientBounds.Y);
	}

	/**
		Allows you to set the position of the window.
	*/
	public @property void Position(Vector2 pos) {
		SDL_SetWindowPosition(this.window, cast(int)pos.X, cast(int)pos.Y);
	}

    this(string name, Rectanglei bounds, bool focus = true) {
		super(name);
        if (!SDL_Init(SDL_INIT_EVERYTHING) < 0) {
            Logger.Fatal("Initialization of SDL2 failed!...\n{0}", SDL_GetError());
        }

		ClientBounds = new WindowBounds(this, bounds);

		ClientBounds.windowResizeRequestEvent ~= (sender, data) {
			BoundsEventArgs dat = cast(BoundsEventArgs)data;
			SDL_SetWindowSize(this.window, dat.Width, dat.Height);
		};

		ClientBounds.windowPositionRequestEvent ~= (sender, data) {
			BoundsEventArgs dat = cast(BoundsEventArgs)data;
			SDL_SetWindowPosition(this.window, dat.X, dat.Y);
		};

		//Set info.
        this.startBounds = bounds;
		this.start_title = name;

		this.AutoFocus = focus;



		//Cap info.
		if (this.startBounds.X == WindowPosition.Center) this.startBounds.X = SDL_WINDOWPOS_CENTERED;
		if (this.startBounds.Y == WindowPosition.Center) this.startBounds.Y = SDL_WINDOWPOS_CENTERED;
		if (this.startBounds.X == WindowPosition.Undefined) this.startBounds.X = SDL_WINDOWPOS_UNDEFINED;
		if (this.startBounds.Y == WindowPosition.Undefined) this.startBounds.Y = SDL_WINDOWPOS_UNDEFINED;
		if (this.startBounds.Width == WindowPosition.Undefined) this.startBounds.Width = 640;
		if (this.startBounds.Height == WindowPosition.Undefined) this.startBounds.Height = 480;
    }

	this (Rectanglei bounds, bool focus = true) {
		this("My Game", bounds, focus);
	}

	this(bool focus = true) {
		this(Rectanglei(WindowPosition.Undefined, WindowPosition.Undefined, 640, 480), focus);
	}

    ~this() {
		if (this.window != null) Close();
        SDL_Quit();
    }

	override GraphicsContext CreateContext(GraphicsBackend backend) {
		ActiveBackend = backend;
		version(OpenGL) {
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
		}
		version(OpenGL_ES) {
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
			SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
			SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
			SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
			SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
		}
		SDL_GLContext context = SDL_GL_CreateContext(this.window);
		if (context == null) throw new Error(to!string(SDL_GetError()));
		ActiveContext = GraphicsContext(context);
		return ActiveContext;
	}

	override void DestroyContext() {
		if (ActiveBackend == GraphicsBackend.OpenGL) {
			SDL_GL_DeleteContext(ActiveContext.ContextPtr);
			Logger.Log("Deleted OpenGL context.");
			return;
		}
		// TODO: Destroy vulkan context.
	}

	override void SwapBuffers() {
		if (ActiveBackend == GraphicsBackend.OpenGL) SDL_GL_SwapWindow(this.window);
	}

	/**
		Triggers an window info update.
	*/
	override void UpdateState() {
		int x, y, width, height;
		SDL_GetWindowPosition(this.window, &x, &y);
		SDL_GetWindowSize(this.window, &width, &height);
		updateBounds(Rectanglei(x, y, width, height));
	}

	/**
		Closes the window.
	*/
	override void Close() {
		SDL_DestroyWindow(this.window);
		//Explicitly destroy window.
		destroy(this.window);
	}

	/**
		Puts the window in focus (ONLY WORKS ON SOME PLATFORMS!)
	*/
	override void Focus() {
		SDL_RaiseWindow(this.window);
	}

	/**
		TODO
		Sets the icon for the window.
	*/
	override void SetIcon() {
		//TODO: When rendering is there, set icon.
	}

	/**
		Shows the window.
	*/
    override void Show() {
		Logger.Debug("Spawning window...");
		this.window = SDL_CreateWindow(this.start_title.toStringz, this.startBounds.X, this.startBounds.Y, this.startBounds.Width, this.startBounds.Height, SDL_WINDOW_OPENGL);
		if (this.window == null) {
			destroy(this.window);
			Logger.Fatal("Window creation error: {0}", SDL_GetError());
		}
		// Enable VSync by default.
		VSync = VSyncState.VSync;

		// Focus window
		if (AutoFocus) this.Focus();
    }
}