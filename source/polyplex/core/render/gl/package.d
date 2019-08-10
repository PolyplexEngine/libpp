module polyplex.core.render.gl;
public import polyplex.core.render.gl.batch;
public import polyplex.core.render.gl.debug2d;
public import polyplex.core.render.gl.renderbuf;
import polyplex.core.render;
import polyplex.core.render.gl.gloo;
static import win = polyplex.core.window;
import polyplex.core.color;
import polyplex.utils;
import polyplex.math;
import polyplex;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.opengl.gl;
import std.conv;
import std.stdio;

public import polyplex.core.render.gl.shader;

// TODO: Remove SDL dependency from this.

public class Renderer {
static:
private:
	win.Window window;
	Rectangle scissorRect;

package(polyplex):
	void setWindow(win.Window parent) {
		this.window = parent;
	}

public:
	win.Window Window() {
		return window;
	}

	void Init() {
		// Create the neccesary rendering backend.
		Window.CreateContext(GraphicsBackend.OpenGL);
		
		loadOpenGL();

		SpriteBatch.InitializeSpritebatch();
		Debugging2D.PrepDebugging();
		
		//Default settings for sprite clamping and wrapping
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		Logger.Info("OpenGL version: {0}", to!string(glGetString(GL_VERSION)));
		GL.Enable (Capability.Blending);
		GL.BlendFunc (GL.SourceAlpha, GL.OneMinusSourceAlpha);
		
		// TODO: reimplement this.
		//Crash if system has unsupported opengl version.
		//if (glver < GLVersion.gl30) throw new Error("Sorry, your graphics card does not support Open GL 3 or above.");
		Logger.Info("OpenGL initialized...");
	}
	
	@property Rectangle ScissorRectangle() {
		return scissorRect;
	}

	@property void ScissorRectangle(Rectangle rect) {
		scissorRect = rect;
		glScissor(
			scissorRect.X, 
			(Renderer.Window.ClientBounds.Height-scissorRect.Y)-scissorRect.Height, 
			scissorRect.Width, 
			scissorRect.Height);
	}

	@property VSyncState VSync() {
		return Window.VSync;
	}

	@property void VSync(VSyncState state) {
		Window.VSync = state;
	}

	void AdjustViewport() {
		glViewport(0, 0, Window.ClientBounds.Width, Window.ClientBounds.Height);
	}

	void ClearColor(Color color) {
		glClearColor(color.Rf, color.Gf, color.Bf, color.Af);
		glClear(GL_COLOR_BUFFER_BIT);
		ClearDepth();
	}

	void ClearDepth() {
		glClear(GL_DEPTH_BUFFER_BIT);
	}

	void SwapBuffers() {
		Window.SwapBuffers();
	}
}
