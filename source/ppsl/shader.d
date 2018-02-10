module ppsl.shader;
import ppsl.errors;
import ppsl.tokens;

enum PPSLCompiler {
	GLSL,
	CG
}

class OutputShader {
	public string FragmentShader;
	public string VertexShader;
}

class PPSLShaderCollection {
	public PPSLShader[] Shaders;

	public void Add(PPSLShader shader) {
		Shaders.length++;
		Shaders[$-1] = shader;
	}
}

public enum PPSLScope {
	Fragment,
	Vertex,
	Total
}

public enum PPSLAttributeDirection {
	In,
	Out,
	Uniform
}

public enum PPSLPlacementLoc {
	PreAttribute,
	Auto
}

class PPSLAttribute {
	public PPSLScope Scope;
	public PPSLAttributeDirection Direction;
	public string Type;
	public string Name;
}

class PPSLShaderCode {
	public PPSLPlacementLoc Location;
	public string Code;
}

class PPSLTechnique {
	public string Name;
	public string ShaderCode;
}

class PPSLShaderScope {
	public PPSLScope Scope;
	public PPSLTechnique[] Techniques;
	public PPSLShaderCode Code;
}

class PPSLShader {
	public string Name;
	public string Version;
	public PPSLAttribute[] Attributes;
	public PPSLShaderScope[] Scopes;
	public PPSLCompiler Compiler;



	private this(PPSLCompiler compiler) {
		if (compiler == PPSLCompiler.CG) {
			throw ERROR_CG_UNSUPPORTED;
		}
		this.Compiler = compiler;
	}
}