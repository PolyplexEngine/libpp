module polyplex.core.render.enums;


public enum VSyncState {
	LateTearing = -1,
	Immidiate = 0,
	VSync = 1
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
		return RasterizerState(true, false, false, false, 0f);
	}

	bool BackfaceCulling;
	bool DepthTest;
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

enum ShaderType {
	Vertex,
	Geometry,
	Fragment,
	
	Stencil,
	Compute
}

enum ShaderLang {
	PPSL,
	GLSL
}
