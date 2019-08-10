module polyplex.core.render.common;
import polyplex.core.render;

/**
    The code of a shader
*/
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