module polyplex.core.render;
public import polyplex.core.render.camera;
public import polyplex.core.render.shapes;

import polyplex.core.render.gl;
import polyplex.core.render.vk;
import polyplex.core.content;
import polyplex.core.color;
import polyplex.math;
import derelict.sdl2.sdl;
import polyplex.math;
import polyplex;
import std.stdio;

public class Renderer {
	private int width;
	private int height;
	
	protected SprBatch sprite_batch;

	public @property SprBatch SpriteBatch() { return this.sprite_batch; }
	public abstract void Init(SDL_Window* win);
	public abstract void ClearColor(Color color);
	public abstract void ClearDepth();
	public abstract void SwapBuffers();
	public abstract Shader CreateShader(ShaderCode code);
	protected abstract void UpdateViewport(int width, int height);

	public void SetViewport(Rectangle size) {
		this.width = size.Width;
		this.height = size.Height;
		UpdateViewport(this.width, this.height);
	}

	public @property Matrix4x4 Project(float znear, float zfar) {
		return Matrix4x4.Orthographic(0f, cast(float)this.width, cast(float)this.height, 0f, znear, zfar);
	}
}


public class SprBatch {
	public abstract void Begin(Camera2D camera);
	public abstract void End();
}

public abstract class Shader {
	public abstract void Attach();
	public abstract void Detach();
	public abstract void SetUniform(int location, float value);
	public abstract void SetUniform(int location, Vector2 value);
	public abstract void SetUniform(int location, Vector3 value);
	public abstract void SetUniform(int location, Vector4 value);
	public abstract void SetUniform(int location, int value);
	public abstract void SetUniform(int location, Vector2i value);
	public abstract void SetUniform(int location, Vector3i value);
	public abstract void SetUniform(int location, Vector4i value);
	public abstract void SetUniform(int location, Matrix2x2 value);
	public abstract void SetUniform(int location, Matrix3x3 value);
	public abstract void SetUniform(int location, Matrix4x4 value);
	public abstract uint GetUniform(string name);

}

enum ShaderType {
	Vertex,
	Fragment,
	Stencil,
	Compute
}

enum ShaderLang {
	PPSL,
	GLSL,

	//For eventual Direct X version?
	//Would be added in PPSL language as support aswell.
	CG
}

class ShaderCode {
	private ShaderLang language;

	public @property ShaderLang Language() { return language; }
	public string Vertex;
	public string Fragment;
	public string[] Attributes;

	this() {}
	this(string vertex, string fragment, string[] attribs) {
		this.Vertex = vertex;
		language = ShaderLang.GLSL;
		if (this.Vertex[0..5] == "shader") {
			language = ShaderLang.PPSL;
		}
		this.Fragment = fragment;
		this.Attributes = attribs;
	}
}

public Renderer CreateBackendRenderer() {
	if (ChosenBackend == GraphicsBackend.Vulkan) return new VkRenderer();
	return new GlRenderer();
}