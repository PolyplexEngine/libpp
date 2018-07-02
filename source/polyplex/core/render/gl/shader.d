module polyplex.core.render.gl.shader;
import polyplex.core.render;
import derelict.sdl2.sdl;
import derelict.opengl;
import polyplex.math;
import polyplex.utils.logging;
import std.conv;


class GLShader : Shader {
	private GLuint shaderprogram;
	private GLuint vertexshader = 0;
	private GLuint fragmentshader = 0;
	private GLuint geometryshader = 0;
	private ShaderCode shadersource;

	this(ShaderCode code) {
		shadersource = code;
		compile_shaders();
		link_shaders();
	}

	~this() {
		glUseProgram(0);
		glDetachShader(shaderprogram, vertexshader);
		if (geometryshader != 0) glDetachShader(shaderprogram, geometryshader);
		glDetachShader(shaderprogram, fragmentshader);
		glDeleteProgram(shaderprogram);
		glDeleteShader(vertexshader);
		if (geometryshader != 0) glDeleteShader(geometryshader);
		glDeleteShader(fragmentshader);
	}
	
	/**
		Vertex Shader Id.
	*/
	public @property GLchar* VertGL() { return cast(GLchar*)(shadersource.Vertex.ptr); }
	
	/**
		Fragment Shader Id.
	*/
	public @property GLchar* FragGL() { return cast(GLchar*)(shadersource.Fragment.ptr); }
	
	/**
		Geometry Shader Id.
	*/
	public @property GLchar* GeoGL() { return cast(GLchar*)(shadersource.Geometry.ptr); }

	/**
		Shader Attributes.
	*/
	public @property GLchar*[] AttribGL() {
		GLchar*[] attributes = new GLchar*[shadersource.Attributes.length];
		for (int i = 0; i < attributes.length; i++) {
			string attr = shadersource.Attributes[i];
			char[] buffer = (attr ~ '\0').dup;
			attributes[i] = buffer.ptr;
		}
		return attributes;
	}

	/**
		Gets whenever this shader is attached.
	*/
	public override @property bool Attached() {
		int i;
		glGetIntegerv(GL_CURRENT_PROGRAM, &i);
		if (i == shaderprogram) return true;
		return false;
	}

	//Uniform stuff.
	public override void SetUniform(int location, float value) { if (!Attached) Attach(); glUniform1f(cast(GLint)location, cast(GLfloat)value); }
	public override void SetUniform(int location, Vector2 value) { if (!Attached) Attach(); glUniform2f(cast(GLint)location, cast(GLfloat)value.X, cast(GLfloat)value.Y); }
	public override void SetUniform(int location, Vector3 value) { if (!Attached) Attach(); glUniform3f(cast(GLint)location, cast(GLfloat)value.X, cast(GLfloat)value.Y, cast(GLfloat)value.Z); }
	public override void SetUniform(int location, Vector4 value) { if (!Attached) Attach(); glUniform4f(cast(GLint)location, cast(GLfloat)value.X, cast(GLfloat)value.Y, cast(GLfloat)value.Z, cast(GLfloat)value.W); }
	public override void SetUniform(int location, int value) { if (!Attached) Attach(); glUniform1i(cast(GLint)location, cast(GLint)value); }
	public override void SetUniform(int location, Vector2i value) { if (!Attached) Attach(); glUniform2i(cast(GLint)location, cast(GLint)value.X, cast(GLint)value.Y); }
	public override void SetUniform(int location, Vector3i value) { if (!Attached) Attach(); glUniform3i(cast(GLint)location, cast(GLint)value.X, cast(GLint)value.Y, cast(GLint)value.Z); }
	public override void SetUniform(int location, Vector4i value) { if (!Attached) Attach(); glUniform4i(cast(GLint)location, cast(GLint)value.X, cast(GLint)value.Y, cast(GLint)value.Z, cast(GLint)value.W); }
	public override void SetUniform(int location, Matrix2x2 value) { if (!Attached) Attach(); glUniformMatrix2fv(location, 1, GL_TRUE, value.ptr); }
	public override void SetUniform(int location, Matrix3x3 value) { if (!Attached) Attach(); glUniformMatrix3fv(location, 1, GL_TRUE, value.ptr); }
	public override void SetUniform(int location, Matrix4x4 value) { if (!Attached) Attach(); glUniformMatrix4fv(location, 1, GL_TRUE, value.ptr); }

	/**
		GetUniform gets the position of a uniform.
	*/
	public override int GetUniform(string name) {
		import std.string;
		return glGetUniformLocation(shaderprogram, name.toStringz);
	}

	/**
		HasUniform checks whenever the shader contains a unform with name "name"
		Returns true if it exists, false otherwise.
	*/
	public override bool HasUniform(string name) {
		auto u = GetUniform(name);
		if (u == -1) return false;
		return true;
	}

	/**
		Attach attaches the shader.
	*/
	public override void Attach() {
		glUseProgram(this.shaderprogram);
	}

	/**
		Detatch detatches the shader. (Binds shader 0)
	*/
	public override void Detach() {
		glUseProgram(0);
	}

	//Shader linking
	private void link_shaders() {
		bind_attribs();
		glLinkProgram(shaderprogram);
		int c;
		glGetProgramiv(shaderprogram, GL_LINK_STATUS, &c);
		if (c == 0) {
			log_shader(shaderprogram, LogType.Program);
			return;
		}
		c = 0;
		glValidateProgram(shaderprogram);
		glGetProgramiv(shaderprogram, GL_VALIDATE_STATUS, &c);
		if (c == 0) {
			log_shader(shaderprogram, LogType.Program);
			return;
		}
		//TODO: Add logging
		//writeln("Compilation completed.");
	}

	private void bind_attribs() {
		GLchar*[] attribs = AttribGL;
		for (int i = 0; i < attribs.length; i++) {
			//TODO: Add logging
			//writeln("Binding attribute ", i, " named ", to!string(attribs[i]));
			Logger.Debug("Binding attribute {0} named {1}...", i, attribs[i]);
			glBindAttribLocation(shaderprogram, i, attribs[i]);
		}
	}

	//Compilation of shaders
	private void compile_shaders() {
		compile_shader(shadersource, ShaderType.Vertex);
		if (!(shadersource.Geometry is null)) compile_shader(shadersource, ShaderType.Geometry);
		compile_shader(shadersource, ShaderType.Fragment);
		shaderprogram = glCreateProgram();
		glAttachShader(shaderprogram, vertexshader);
		if (!(shadersource.Geometry is null)) glAttachShader(shaderprogram, geometryshader);
		glAttachShader(shaderprogram, fragmentshader);
	}

	private void compile_shader(ShaderCode code, ShaderType type) {
		if (type == ShaderType.Vertex) {
			vertexshader = glCreateShader(GL_VERTEX_SHADER);

			//Get source
			int l = cast(int)shadersource.Vertex.length;
			GLchar* cs = VertGL;
			glShaderSource(vertexshader, 1, &cs, &l);

			//Compile
			glCompileShader(vertexshader);
			int c;
			glGetShaderiv(vertexshader, GL_COMPILE_STATUS, &c);
			if (c == 0) {
				log_shader(vertexshader);
				return;
			}
		} else if (type == ShaderType.Geometry) {
			geometryshader = glCreateShader(GL_GEOMETRY_SHADER);

			//Get source
			int l = cast(int)shadersource.Geometry.length;
			GLchar* cs = GeoGL;
			glShaderSource(geometryshader, 1, &cs, &l);

			//Compile
			glCompileShader(geometryshader);
			int c;
			glGetShaderiv(geometryshader, GL_COMPILE_STATUS, &c);
			if (c == 0) {
				log_shader(geometryshader);
				return;
			}
		} else {
			fragmentshader = glCreateShader(GL_FRAGMENT_SHADER);
			
			//Get source
			int l = cast(int)shadersource.Fragment.length;
			GLchar* cs = FragGL;
			glShaderSource(fragmentshader, 1, &cs, &l);

			//Compile
			glCompileShader(fragmentshader);
			int c;
			glGetShaderiv(fragmentshader, GL_COMPILE_STATUS, &c);
			if (c != GL_TRUE) {
				log_shader(fragmentshader);
				return;
			}
		}
	}

	enum LogType {
		Program,
		Shader
	}
	
	private void log_shader(GLuint port, LogType type = LogType.Shader) {
		if (type == LogType.Shader) {
			int maxlen = 512;
			char[] logmsg;
			logmsg.length = maxlen;
			glGetShaderInfoLog(port, maxlen, &maxlen, logmsg.ptr);
			throw new Error("GLSLShaderError (shader: " ~ to!string(port) ~ ")" ~ to!string(logmsg[0..maxlen]));
		}
		int maxlen = 512;
		char[] logmsg;
		logmsg.length = maxlen;
		glGetProgramInfoLog(port, maxlen, &maxlen, logmsg.ptr);
		throw new Error("GLSLProgramError (program: " ~ to!string(port) ~ ")" ~ to!string(logmsg[0..maxlen]));
	}
}

