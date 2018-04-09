module polyplex.core.render.gl;
import polyplex.core.render.gl.batch;
import polyplex.core.render;
import polyplex.core.window;
import polyplex.core.color;
import polyplex.utils;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.opengl;
import derelict.opengl.gl;
import std.conv;
import std.stdio;

public import polyplex.core.render.gl.shader;

public class GlRenderer : Renderer {
	private SDL_Window* win;
	private SDL_GLContext context;

	this(GameWindow parent) { super(parent); }

	~this() {
		SDL_GL_DeleteContext(context);
		Logger.Log("Deleted OpenGL context.");
	}

	public override void Init(SDL_Window* w) {
		win = w;
		context = SDL_GL_CreateContext(w);
		auto glver = DerelictGL3.reload();
		if (context == null) throw new Error(to!string(SDL_GetError()));
		int wd, hd;
		SDL_GetWindowSize(w, &wd, &hd);
		GlSpriteBatch.InitializeSpritebatch();
		Renderer r = cast(Renderer)this;
		this.Batch = new GlSpriteBatch(r);
		
		//Default settings for sprite clamping and wrapping
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		Logger.Log("OpenGL version: {0}", to!string(glGetString(GL_VERSION)), LogType.Info);
		glEnable (GL_BLEND);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//Crash if system has unsupported opengl version.
		if (glver < GLVersion.gl30) throw new Error("Sorry, your graphics card does not support Open GL 3 or above.");
		Logger.Log("OpenGL initialized...");
	}
	
	public override @property bool VSync() {
		int i = SDL_GL_GetSwapInterval();
		if (i == 1) return true;
		return false;
	}

	public override @property void VSync(VSyncState state) {
		SDL_GL_SetSwapInterval(state);
	}

	public override void AdjustViewport() {
		glViewport(0, 0, Window.Width, Window.Height);
	}

	public override void ClearColor(Color color) {
		glClearColor(color.Rf, color.Gf, color.Bf, color.Af);
		glClear(GL_COLOR_BUFFER_BIT);
		ClearDepth();
	}

	public override void ClearDepth() {
		glClear(GL_DEPTH_BUFFER_BIT);
	}

	public override void SwapBuffers() {
		SDL_GL_SwapWindow(win);
	}

	public override Shader CreateShader(ShaderCode code) {
		return new GLShader(code);
	}
}