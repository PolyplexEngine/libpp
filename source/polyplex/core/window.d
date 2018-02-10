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


public class WindowInfo {
    public string Name;
    public Rectangle Bounds;
}

public class GameWindow {
	private int width;
	private int height;
    private SDL_Window* window;
	private Renderer renderer;
    private WindowInfo inf;

	public @property int Width() { return this.width; }
	public @property int Height() { return this.height; }

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
		return Rectangle(x, y, width, height);
	}

    this(WindowInfo info) {
		//Initialize SDL.
        Logger.Debug("Creating window...");
        if (!SDL_Init(SDL_INIT_EVERYTHING) < 0) {
            Logger.Fatal("Initialization of SDL2 failed!...\n{0}", SDL_GetError());
        }

		if (!IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_WEBP) < 0 ) {
			Logger.Fatal("Initialization of image formats failed!...\n{0}", IMG_GetError());
		}
		//Create window.
        Logger.Debug("GameWindow created!");

		//Set info.
        this.inf = info;
    }

    ~this() {
		if (this.window != null) Close();
        SDL_Quit();
    }

	void UpdateInfo() {
		SDL_GetWindowSize(this.window, &width, &height);
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
		if (polyplex.ChosenBackend == polyplex.GraphicsBackend.Vulkan) this.window = SDL_CreateWindow(inf.Name.dup.ptr, inf.Bounds.X, inf.Bounds.Y, inf.Bounds.Width, inf.Bounds.Height, SDL_WINDOW_VULKAN);
		else this.window = SDL_CreateWindow(inf.Name.dup.ptr, inf.Bounds.X, inf.Bounds.Y, inf.Bounds.Width, inf.Bounds.Height, SDL_WINDOW_OPENGL);
		this.renderer = CreateBackendRenderer();
		this.renderer.Init(this.window);
		if (this.window == null) {
			destroy(this.window);
			Logger.Fatal("Window creation error: {0}", SDL_GetError());
		}
    }
}