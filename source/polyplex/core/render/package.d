module polyplex.core.render;
public import polyplex.core.render.camera;
public import polyplex.core.render.shapes;

import polyplex.core.render.gl;
import polyplex.core.render.vk;
import polyplex.core.render.simplefont;
import polyplex.core.content;
import polyplex.core.color;
import polyplex.core.content;
import polyplex.core.window;
import polyplex.math;
import derelict.sdl2.sdl;
import polyplex.math;
import polyplex;
import std.stdio;

public enum VSyncState {
	LateTearing = -1,
	Immidiate = 0,
	VSync = 1
}

public class Renderer {
	public SpriteBatch Batch;
	public GameWindow Window;

	this(GameWindow parent) {
		this.Window = parent;
	}

	public abstract void Init(SDL_Window* win);
	public abstract void ClearColor(Color color);
	public abstract void ClearDepth();
	public abstract void SwapBuffers();
	public abstract Shader CreateShader(ShaderCode code);

	public abstract void AdjustViewport();

	public abstract @property VSyncState VSync();
	public abstract @property void VSync(VSyncState state);
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
	LinearClamp,
	LinearWrap,
	PointClamp,
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
	public static RasterizerState Default() {
		return RasterizerState(false, false, 0f);
	}

	public bool ScissorTest;
	public bool MSAA;
	public float SlopeScaleBias;
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
	public abstract void Begin();
	public abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, RasterizerState raster_state, Shader s, Matrix4x4 matrix);
	public abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_State, RasterizerState raster_state, Shader s, Camera camera);
	public abstract void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_State, RasterizerState raster_state, ProjectionState pstate, Shader s, Camera camera);
	public abstract void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	public abstract void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, float rotation, Vector2 Origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	public abstract void DrawAABB(Texture2D texture, Rectangle pos_top, Rectangle pos_bottom, Rectangle cutout, Vector2 Origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f);
	
	public abstract void Flush();
	public abstract void SwapChain();
	public abstract void End();
}

public abstract class Shader {
	public abstract @property bool Attached();

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
	public abstract bool HasUniform(string name);

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
	private ShaderLang language;

	public @property ShaderLang Language() { return language; }
	public string Vertex;
	public string Fragment;
	public string Geometry;
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

	this(string vertex, string geometry, string fragment, string[] attribs) {
		this.Vertex = vertex;
		this.Geometry = geometry;
		language = ShaderLang.GLSL;
		if (this.Vertex[0..5] == "shader") {
			language = ShaderLang.PPSL;
		}
		this.Fragment = fragment;
		this.Attributes = attribs;
	}
}

public Renderer CreateBackendRenderer(GameWindow parent) {
	if (ChosenBackend == GraphicsBackend.Vulkan) return new VkRenderer(parent);
	return new GlRenderer(parent);
}