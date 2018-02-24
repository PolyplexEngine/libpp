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
static import std.file;

public static GraphicsBackend ChosenBackend = GraphicsBackend.OpenGL;
private static bool sdl_init = false;
private static bool vk_init = false;
private static bool gl_init = false;


public enum GraphicsBackend {
	Vulkan,
	OpenGL
}

private string get_arch() {
	version(X86) return "i386";
	version(X86_64) return "amd64";
	version(ARM) return "arm";
	version(AArch64) return "arm64";
}

private string get_system_lib(string libname, bool s = true) {
	string lstr = "libs/"~get_arch()~"/lib"~libname~".so";

	string plt = "linux/bsd";
	version(Windows) {
		lstr = "libs/"~get_arch()~"/"~libname~".dll";
		plt = "win32";
	}
	
	version(FreeBSD) {
		lstr = "libs/"~get_arch()~"/lib"~libname~"-freebsd.so";
		plt = "linux/bsd";
	}
	
	version(OpenBSD) {
		lstr = "libs/"~get_arch()~"/lib"~libname~"-openbsd.so";
		plt = "linux/bsd";
	}

	version(OSX) {
		lstr = "libs/"~get_arch()~"/lib"~libname~".dylib";
		plt = "darwin/osx";
	}
	Logger.Info("Binding library {0}: [{1} on {2}] from {3}", libname, plt, get_arch(), lstr);
	return lstr;
}

/*
	InitLibraries loads the Derelict libraries for Vulkan, SDL and OpenGL
*/
public void InitLibraries() {
	if (!sdl_init) {
		if (std.file.exists("libs/")) {
			// Load bundled libraries.
			Logger.Info("Binding to runtime libraries...");
			DerelictSDL2.load(get_system_lib("SDL2"));
			DerelictSDL2Image.load(get_system_lib("SDL2_image"));
			DerelictSDL2Mixer.load(get_system_lib("SDL2_mixer"));
			DerelictSDL2ttf.load(get_system_lib("SDL2_ttf"));
		} else {
			// Load system libraries
			Logger.Info("Binding to system libraries....");
			DerelictSDL2.load();
			DerelictSDL2Image.load();
			DerelictSDL2Mixer.load();
			DerelictSDL2ttf.load();
		}
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