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
		SetViewport(Rectangle(0, 0, wd, hd));
		this.sprite_batch = new GlSpriteBatch();
		
		Logger.Log("OpenGL version: {0}", to!string(glGetString(GL_VERSION)), LogType.Info);

		//Crash if system has unsupported opengl version.
		if (glver < GLVersion.gl30) throw new Error("Sorry, your graphics card does not support Open GL 3 or above.");
	}
	
	public override void ClearColor(Color color) {
		glClearColor(color.Red, color.Green, color.Blue, color.Alpha);
		glClear(GL_COLOR_BUFFER_BIT);
	}
	
	protected override void UpdateViewport(int width, int height) {
		glViewport(0, 0, width, height);
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