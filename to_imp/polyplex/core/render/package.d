module polyplex.core.render;
public import polyplex.core.render.camera;
public import polyplex.core.render.shapes;

import polyplex.core.color;
//import polyplex.core.content;
static import win = polyplex.core.window;
import polyplex.math;
//import bindbc.sdl;
import polyplex.math;
//import polyplex;
import std.stdio;

public enum VSyncState {
	LateTearing = -1,
	Immidiate = 0,
	VSync = 1
}

public class Renderer {
private:
	static BackendRenderer BGRend;

public:
	static win.Window Window;

	/**
		Backend function, run automatically, no need to invoke it manually. c:
	*/
	static void AssignRenderer(win.Window parent) {
		BGRend = CreateBackendRenderer(parent);
		BGRend.Init();
		Window = parent;
	}

	static void ClearColor(Color color) {
		BGRend.ClearColor(color);
	}

	static void ClearDepth() {
		BGRend.ClearDepth();
	}

	static void SwapBuffers() {
		BGRend.SwapBuffers();
	}

	static Shader CreateShader(ShaderCode code) {
		return BGRend.CreateShader(code);
	}

	static void AdjustViewport() {
		BGRend.AdjustViewport();
	}

	static @property VSyncState VSync() {
		return BGRend.VSync;
	}

	static @property void VSync(VSyncState state) {
		BGRend.VSync = state;
	}

	static @property Rectangle ScissorRectangle() {
		return BGRend.ScissorRectangle;
	}

	static @property void ScissorRectangle(Rectangle rect) {
		BGRend.ScissorRectangle = rect;
	}

	static SpriteBatch NewBatcher() {
		return new GlSpriteBatch();
	}

}

public class BackendRenderer {
public:
	SpriteBatch Batch;
	win.Window Window;

	this(win.Window parent) {
		this.Window = parent;
	}

	abstract void Init();
	abstract void ClearColor(Color color);
	abstract void ClearDepth();
	abstract void SwapBuffers();
	abstract Shader CreateShader(ShaderCode code);

	abstract void AdjustViewport();

	abstract @property VSyncState VSync();
	abstract @property void VSync(VSyncState state);

	abstract @property Rectangle ScissorRectangle();
	abstract @property void ScissorRectangle(Rectangle rect);
}

public enum Blending {
	Opqaue,
	AlphaBlend,
	NonPremultiplied,
	Additive 
}

public enum ProjectionState {
	Orthographic,
	Perspective
}

public enum Sampling {
	AnisotropicClamp,
	AnisotropicWrap,
	AnisotropicMirror,
	LinearClamp,
	LinearWrap,
	LinearMirror,
	PointClamp,
	PointMirror,
	PointWrap
}

public enum SpriteSorting {
	BackToFront,
	Deferred,
	FrontToBack,
	Immediate,
	Texture
}

public struct RasterizerState {
public:
	static RasterizerState Default() {
		return RasterizerState(false, false, 0f);
	}

	bool ScissorTest;
	bool MSAA;
	float SlopeScaleBias;
}

/*
public enum Stencil {
	Default,
	DepthRead,
	None
}*/

public enum SpriteFlip {
	None = 0x0,
	FlipVertical = 0x1,
	FlipHorizontal = 0x2
}

public abstract class SpriteBatch {
public:
	bool OffsetOrigin = true;
	abstract Matrix4x4 MultMatrices();
	abstract void Begin();
	abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, RasterizerState raster_state, Shader s, Matrix4x4 matrix);
	abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_State, RasterizerState raster_state, Shader s, Camera camera);
	abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_State, RasterizerState raster_state, ProjectionState pstate, Shader s, Camera camera);
	abstract void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	abstract void Draw(Framebuffer texture, Rectangle pos, Rectangle cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	abstract void Draw(Framebuffer texture, Rectangle pos, Rectangle cutout, float rotation, Vector2 origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	abstract void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, float rotation, Vector2 origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	abstract void DrawAABB(Texture2D texture, Rectangle pos_top, Rectangle pos_bottom, Rectangle cutout, Vector2 Origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	abstract void Flush();
	abstract void SwapChain();
	abstract void End();
}

public class Framebuffer {
private:
	FramebufferImpl implementation;

public:
	@property int Width() {
		return implementation.Width;
	}

	@property int Height() {
		return implementation.Height;
	}

	this(int width, int height, int colorAttachments = 1) {
		implementation = new GlFramebufferImpl(width, height, colorAttachments);
	}

	void Begin() {
		implementation.Begin();
	}

	void Resize(int width, int height, int colorAttachments = 1) {
		implementation.Resize(width, height, colorAttachments);
	}

	void End() {
		GlFramebufferImpl.End();
		Renderer.AdjustViewport();
	}

	FramebufferImpl Implementation() {
		return implementation;
	}
}

public abstract class FramebufferImpl {
protected:
	int width;
	int height;

public:

	this(int width, int height, int colorAttachments) {
		this.width = width;
		this.height = height;
	}

	abstract @property int Width();
	abstract @property int Height();
	abstract void Resize(int width, int height, int colorAttachments = 1);
	abstract void Begin();
}

public abstract class Shader {
public:
	abstract @property bool Attached();
	abstract void Attach();
	abstract void Detach();
	abstract void SetUniform(int location, float value);
	abstract void SetUniform(int location, Vector2 value);
	abstract void SetUniform(int location, Vector3 value);
	abstract void SetUniform(int location, Vector4 value);
	abstract void SetUniform(int location, int value);
	abstract void SetUniform(int location, Vector2i value);
	abstract void SetUniform(int location, Vector3i value);
	abstract void SetUniform(int location, Vector4i value);
	abstract void SetUniform(int location, Matrix2x2 value);
	abstract void SetUniform(int location, Matrix3x3 value);
	abstract void SetUniform(int location, Matrix4x4 value);
	abstract int GetUniform(string name);
	abstract bool HasUniform(string name);

}

enum ShaderType {
	Vertex,
	Geometry,
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
private:
	ShaderLang language;

public:
	@property ShaderLang Language() { return language; }
	string Vertex;
	string Fragment;
	string Geometry;

	this() {}

	this(string vertex, string fragment) {
		this.Vertex = vertex;
		language = ShaderLang.GLSL;
		if (this.Vertex[0..5] == "shader") {
			language = ShaderLang.PPSL;
		}
		this.Fragment = fragment;
	}

	this(string vertex, string geometry, string fragment) {
		this.Vertex = vertex;
		this.Geometry = geometry;
		language = ShaderLang.GLSL;
		if (this.Vertex[0..5] == "shader") {
			language = ShaderLang.PPSL;
		}
		this.Fragment = fragment;
	}
}

public BackendRenderer CreateBackendRenderer(win.Window parent) {
	return new GlRenderer(parent);
}
