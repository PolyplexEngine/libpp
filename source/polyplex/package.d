module polyplex;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
import derelict.vulkan.vulkan;
import derelict.opengl;
import polyplex.utils.logging;
import std.stdio;
import std.conv;

public static GraphicsBackend ChosenBackend = GraphicsBackend.OpenGL;
private static bool sdl_init = false;
private static bool vk_init = false;
private static bool gl_init = false;


public enum GraphicsBackend {
	Vulkan,
	OpenGL
}

/*
	InitLibraries loads the Derelict libraries for Vulkan, SDL and OpenGL
*/
public void InitLibraries() {
	if (!sdl_init) {
		DerelictSDL2.load();
		DerelictSDL2Image.load();
		DerelictSDL2Mixer.load();
		DerelictSDL2ttf.load();
		SDL_version linked;
		SDL_version compiled;
		SDL_GetVersion(&linked);
		SDL_VERSION(&compiled);
		Logger.Log("SDL (compiled against): {0}.{1}.{2}", to!string(compiled.major), to!string(compiled.minor), to!string(compiled.patch), LogType.Info);
		Logger.Log("SDL (linked): {0}.{1}.{2}", to!string(linked.major), to!string(linked.minor), to!string(linked.patch), LogType.Info);
		sdl_init = true;
	}

	if (ChosenBackend == GraphicsBackend.Vulkan) {
		if (gl_init) DerelictGL3.unload();
		gl_init = false;


		//Load vulkan... twice...
		DerelictVulkan.load();
		SDL_Vulkan_LoadLibrary(null);
		SDL_VideoInit(null);

		vk_init = true;
		Logger.Info("Intialized Vulkan... ");

		return;
	}
	else {
		if (vk_init) {
			DerelictVulkan.unload();
			SDL_Vulkan_UnloadLibrary();
		}
		vk_init = false;
		
		DerelictGL3.load();
		gl_init = true;
		Logger.Info("Initialized OpenGL...");
	}
}