module polyplex.core.surfaces.sdlwindow;
import polyplex.core.rendersurface;
import polyplex;
import polyplex.utils.sdlbool;
public import polyplex.core.render;
static import polyplex;

import derelict.sdl2.sdl;
import derelict.opengl;
import polyplex.math;
import polyplex.utils.logging;
import std.stdio;
import std.string;
import std.conv;


public enum WindowPosition {
	Center = -1,
	Undefined = 0
}

public class SDLGameWindow : RenderSurface {
	private string start_title;
	private int width;
	private int height;
    private SDL_Window* window;
	private Rectangle start_bounds;

	public @property int Width() { return this.width; }
	public @property int Height() { return this.height; }

	/*
		Gets whenever the window is visible
	*/
    public override @property bool Visible() { return (this.window !is null); }

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
	public override @property string Title() { return to!string(SDL_GetWindowTitle(this.window)); }
	public override @property void Title(string value) { return SDL_SetWindowTitle(this.window, value.toStringz); }

	//Brightness
	public @property float Brightness() { return SDL_GetWindowBrightness(this.window); }
	public @property void Brightness(float b) { SDL_SetWindowBrightness(this.window, b); }

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

	/*
		Returns the raw placement of the window.
		Use RealPlacement if you want your application to be dpi aware.
	*/
	public override @property Rectangle ClientBounds() {
		int x, y;
		SDL_GetWindowPosition(this.window, &x, &y);
		return new Rectangle(x, y, width, height);
	}

	/**
		Returns the position of the window.
	*/
	public @property Vector2 Position() {
		Rectangle r = ClientBounds();
		return Vector2(r.X, r.Y);
	}

	/**
		Allows you to set the position of the window.
	*/
	public @property void Position(Vector2 pos) {
		SDL_SetWindowPosition(this.window, cast(int)pos.X, cast(int)pos.Y);
	}

    this(string name, Rectangle bounds, bool focus = true) {
		super(name);
        if (!SDL_Init(SDL_INIT_EVERYTHING) < 0) {
            Logger.Fatal("Initialization of SDL2 failed!...\n{0}", SDL_GetError());
        }

		//Set info.
        this.start_bounds = bounds;
		this.start_title = name;

		this.AutoFocus = focus;

		//Cap info.
		if (this.start_bounds is null) this.start_bounds = new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 640, 480);
		if (this.start_bounds.X == WindowPosition.Center) this.start_bounds.X = SDL_WINDOWPOS_CENTERED;
		if (this.start_bounds.Y == WindowPosition.Center) this.start_bounds.Y = SDL_WINDOWPOS_CENTERED;
		if (this.start_bounds.X == WindowPosition.Undefined) this.start_bounds.X = SDL_WINDOWPOS_UNDEFINED;
		if (this.start_bounds.Y == WindowPosition.Undefined) this.start_bounds.Y = SDL_WINDOWPOS_UNDEFINED;
		if (this.start_bounds.Width == WindowPosition.Undefined) this.start_bounds.Width = 640;
		if (this.start_bounds.Height == WindowPosition.Undefined) this.start_bounds.Height = 480;
    }

	this (Rectangle bounds, bool focus = true) {
		this("My Game", bounds, focus);
	}

	this(bool focus = true) {
		this(new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, 640, 480), focus);
	}

    ~this() {
		if (this.window != null) Close();
        SDL_Quit();
    }

	override GraphicsContext CreateContext(GraphicsBackend backend) {
		if (backend is GraphicsBackend.OpenGL) {
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
			SDL_GLContext context = SDL_GL_CreateContext(this.window);
			DerelictGL3.reload();
			if (context == null) throw new Error(to!string(SDL_GetError()));
			return GraphicsContext(context);
		}
		// TODO: Create an Vulkan context.
		import polyplex.core.render.vk;
		import derelict.vulkan;
		import derelict.vulkan.base;
		VkInstance instance;

		// Create instance via SDL, by first making a dummy-esque application info, then making an instance from that.
		ApplicationInfo info = ApplicationInfo(this.Title, "libpp", Version(1, 0, 0), Version(1, 0, 0), Version.VulkanAPIVersion);
		
		// Get list of required extensions.
		uint arrLen;
		const(char)** arr;
		SDL_Vulkan_GetInstanceExtensions(this.window, &arrLen, arr);

		// Create InstanceCreateInfo.
		VkInstanceCreateInfo createInfo = VkInstanceCreateInfo(
			VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
			null,
			0,
			info.ptr, 
			0,
			null, 
			arrLen, 
			arr
		);

		// Create instance and return it.
		vkCreateInstance(&createInfo, null, &instance);
		return GraphicsContext(instance);
	}

	/**
		Triggers an window info update.
	*/
	override void UpdateState() {
		SDL_GetWindowSize(this.window, &this.width, &this.height);
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
	void Focus() {
		SDL_RaiseWindow(this.window);
	}

	/**
		TODO
		Sets the icon for the window.
	*/
	void SetIcon() {
		//TODO: When rendering is there, set icon.
	}

	/**
		Shows the window.
	*/
    override void Show() {
		Logger.Debug("Spawning window...");
		if (polyplex.ChosenBackend == polyplex.GraphicsBackend.Vulkan) this.window = SDL_CreateWindow(this.start_title.dup.ptr, this.start_bounds.X, this.start_bounds.Y, this.start_bounds.Width, this.start_bounds.Height, SDL_WINDOW_VULKAN);
		else this.window = SDL_CreateWindow(this.start_title.toStringz, this.start_bounds.X, this.start_bounds.Y, this.start_bounds.Width, this.start_bounds.Height, SDL_WINDOW_OPENGL);
		Renderer.AssignRenderer(this, this.window);
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
