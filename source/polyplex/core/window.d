module polyplex.core.window;
import polyplex.utils.sdlbool;
import polyplex.core.render;
static import polyplex;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import polyplex.math;
import polyplex.utils.logging;
import std.stdio;
import std.conv;


public enum WindowPosition {
	Center = -1,
	Undefined = 0
}

public class GameWindow {
	private int width;
	private int height;
    private SDL_Window* window;
	private Renderer renderer;
	private string start_title;
	private Rectangle start_bounds;

	public @property int Width() { return this.width; }
	public @property int Height() { return this.height; }

	public @property Renderer Backend() { return this.renderer; }

	/*
		Gets whenever the window is visible
	*/
    public @property bool Visible() { return (this.window != null); }

	//Resizing
	public @property bool AllowResizing() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & SDL_WINDOW_RESIZABLE) > 0);
	}
	public @property void AllowResizing(bool allow) { SDL_SetWindowResizable(this.window, ToSDL(allow)); }

	//Vertical Syncronization
	public @property bool VSync() {
		return renderer.VSync;
	}
	public @property void VSync(bool allow) {renderer.VSync = allow; }


	//Borderless
	public @property bool Borderless() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & SDL_WINDOW_BORDERLESS) > 0);
	}

	public @property void Borderless(bool i) { SDL_SetWindowBordered(this.window, ToSDL(!i)); }

	//Title
	public @property string Title() { return to!string(SDL_GetWindowTitle(this.window)); }
	public @property void Title(string t) { return SDL_SetWindowTitle(this.window, t.dup.ptr); }

	//Brightness
	public @property float Brightness() { return SDL_GetWindowBrightness(this.window); }
	public @property void Brightness(float b) { SDL_SetWindowBrightness(this.window, b); }

	//Backend
	public @property polyplex.GraphicsBackend GLBackend() { return polyplex.ChosenBackend; }

	//Fullscreen
	public @property bool Fullscreen() {
		SDL_WindowFlags flags = SDL_GetWindowFlags(window);
		return ((flags & (SDL_WINDOW_FULLSCREEN | SDL_WINDOW_FULLSCREEN_DESKTOP)) > 0);
	}

	public @property void Fullscreen(bool i) {
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

	//Renderer
	public @property Renderer Drawing() { return this.renderer; }

	/*
		Returns the raw placement of the window.
		Use RealPlacement if you want your application to be dpi aware.
	*/
	public @property Rectangle Placement() {
		int x, y;
		SDL_GetWindowPosition(this.window, &x, &y);
		return new Rectangle(x, y, width, height);
	}

	public @property Vector2 Position() {
		Rectangle r = Placement();
		return Vector2(r.X, r.Y);
	}

	public @property void Position(Vector2 pos) {
		SDL_SetWindowPosition(this.window, cast(int)pos.X, cast(int)pos.Y);
	}

    this(string name, Rectangle bounds) {
        if (!SDL_Init(SDL_INIT_EVERYTHING) < 0) {
            Logger.Fatal("Initialization of SDL2 failed!...\n{0}", SDL_GetError());
        }

		if (!IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_WEBP) < 0 ) {
			Logger.Fatal("Initialization of image formats failed!...\n{0}", IMG_GetError());
		}

		//Set info.
        this.start_bounds = bounds;
		this.start_title = name;

		//Cap info.
		if (this.start_bounds is null) this.start_bounds = new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 640, 480);
		if (this.start_bounds.X == WindowPosition.Center) this.start_bounds.X = SDL_WINDOWPOS_CENTERED;
		if (this.start_bounds.Y == WindowPosition.Center) this.start_bounds.Y = SDL_WINDOWPOS_CENTERED;
		if (this.start_bounds.X == WindowPosition.Undefined) this.start_bounds.X = SDL_WINDOWPOS_UNDEFINED;
		if (this.start_bounds.Y == WindowPosition.Undefined) this.start_bounds.Y = SDL_WINDOWPOS_UNDEFINED;
		if (this.start_bounds.Width == WindowPosition.Undefined) this.start_bounds.Width = 640;
		if (this.start_bounds.Height == WindowPosition.Undefined) this.start_bounds.Height = 480;
    }

	this (Rectangle bounds) {
		this("My Game", bounds);
	}

	this() {
		this(new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 640, 480));
	}

    ~this() {
		if (this.window != null) Close();
        SDL_Quit();
    }

	void UpdateInfo() {
		SDL_GetWindowSize(this.window, &this.width, &this.height);
	}

	void Close() {
		SDL_DestroyWindow(this.window);
		IMG_Quit();
		//Explicitly destroy window.
		destroy(this.window);
	}

	void Focus() {
		SDL_RaiseWindow(this.window);
	}

	void SetIcon() {
		//TODO: When rendering is there, set icon.
	}

	void SwapBuffers() {
		this.renderer.SwapBuffers();
	}

    void Show() {
		Logger.Debug("Spawning window...");
		if (polyplex.ChosenBackend == polyplex.GraphicsBackend.Vulkan) this.window = SDL_CreateWindow(this.start_title.dup.ptr, this.start_bounds.X, this.start_bounds.Y, this.start_bounds.Width, this.start_bounds.Height, SDL_WINDOW_VULKAN);
		else this.window = SDL_CreateWindow(this.start_title.dup.ptr, this.start_bounds.X, this.start_bounds.Y, this.start_bounds.Width, this.start_bounds.Height, SDL_WINDOW_OPENGL);
		this.renderer = CreateBackendRenderer(this);
		this.renderer.Init(this.window);
		if (this.window == null) {
			destroy(this.window);
			Logger.Fatal("Window creation error: {0}", SDL_GetError());
		}

		this.Focus();
    }
}