module polyplex;
import derelict.vulkan.vulkan;

import bindbc.sdl;
import bindbc.opengl;
import openal;

import polyplex.utils.logging;
import std.stdio;
import std.conv;
static import std.file;
static import std.process;

public import polyplex.core;
public import polyplex.math;
public import polyplex.utils.logging;


public static GraphicsBackend ChosenBackend = GraphicsBackend.OpenGL;
private static bool core_init = false;
private static bool vk_init = false;
private static bool gl_init = false;


public enum GraphicsBackend {
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

private string trimexe(string input) {
	string i = input;
	version(Windows) {
		while (i[i.length-1] != '\\') {
			i.length--;
		}
		return i;
	}
	else {
		while (i[i.length-1] != '/') {
			i.length--;
		}
		return i;
	}
}

/**
	De-init libraries
*/
public void UnInitLibraries() {
	unloadSDL();
	unloadOpenGL();
	unloadOAL();
	core_init = false;
}

/*
	InitLibraries loads the Derelict libraries for Vulkan, SDL and OpenGL
*/
public void InitLibraries() {
	if (!core_init) {
		if (std.file.exists("libs/")) {
			// Load bundled libraries.
			Logger.Info("Binding to runtime libraries...");
			string path_sep = ":";
			string sys_sep = "/";
			version(Windows) {
				path_sep = ";";
				sys_sep = "\\";
			}
			string path = std.process.environment["PATH"];
			string path_begin = std.file.thisExePath();
			path_begin = trimexe(path_begin);
			std.process.environment["PATH"] = path_begin ~ "libs" ~ sys_sep ~ get_arch() ~ path_sep ~ path;
			Logger.Debug("Updated PATH to {0}", std.process.environment["PATH"]);
			loadSDL(get_system_lib("SDL2").dup.ptr);
		} else {
			// Load system libraries
			Logger.Info("Binding to system libraries....");
			loadSDL();
		}
		loadOAL();
		SDL_version linked;
		SDL_version compiled;
		SDL_GetVersion(&linked);
		SDL_VERSION(&compiled);
		Logger.Debug("SDL (compiled against): {0}.{1}.{2}", to!string(compiled.major), to!string(compiled.minor), to!string(compiled.patch));
		Logger.Debug("SDL (linked): {0}.{1}.{2}", to!string(linked.major), to!string(linked.minor), to!string(linked.patch));
		core_init = true;
	}
	loadOpenGL();
	gl_init = true;
}