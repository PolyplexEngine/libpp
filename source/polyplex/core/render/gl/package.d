module polyplex.core.render.gl;
public import polyplex.core.render.gl.batch;
public import polyplex.core.render.gl.debug2d;
import polyplex.core.render;
import polyplex.core.rendersurface;
import polyplex.core.color;
import polyplex.utils;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.opengl;
import derelict.opengl.gl;
import std.conv;
import std.stdio;

public import polyplex.core.render.gl.shader;

// TODO: Remove SDL dependency from this.

public class GlRenderer : BackendRenderer {
	private SDL_Window* win;
	private SDL_GLContext context;

	this(RenderSurface parent) { super(parent); }

	~this() {
		SDL_GL_DeleteContext(context);
		Logger.Log("Deleted OpenGL context.");
	}

	public override void Init(SDL_Window* w) {
		GlSpriteBatch.InitializeSpritebatch();
		GlDebugging2D.PrepDebugging();
		
		//Default settings for sprite clamping and wrapping
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		Logger.Info("OpenGL version: {0}", to!string(glGetString(GL_VERSION)));
		glEnable (GL_BLEND);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		// TODO: reimplement this.
		//Crash if system has unsupported opengl version.
		//if (glver < GLVersion.gl30) throw new Error("Sorry, your graphics card does not support Open GL 3 or above.");
		Logger.Info("OpenGL initialized...");
	}
	
	public override @property VSyncState VSync() {
		return cast(VSyncState)SDL_GL_GetSwapInterval();
	}

	public override @property void VSync(VSyncState state) {
		SDL_GL_SetSwapInterval(state);
	}

	public override void AdjustViewport() {
		glViewport(0, 0, Surface.ClientBounds.Width, Surface.ClientBounds.Height);
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
