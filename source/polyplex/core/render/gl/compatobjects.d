module polyplex.core.render.gl.compatobjects;
import polyplex.core.render.shapes;
import polyplex.core.color;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils.logging;
import std.stdio;
import std.conv;
import std.format;
import std.traits;

enum DrawType {
	LineStrip,
	TriangleStrip,
	Triangles
}

enum OptimizeMode {
	Mode3D,
	Mode2D
}

enum BufferMode {
	Static = GL_STATIC_DRAW,
	Dynamic = GL_DYNAMIC_DRAW
}


class CRenderObject {
	private CVAO vao;
	private CVBO vbo;
	private CIBO ibo;
	private OptimizeMode optimize_for;
	private BufferMode buff_mode;

	public @property CVBO* Vbo() { return &vbo; }
	public @property CVAO* Vao() { return &vao; }
	public @property CIBO* Ibo() { return &ibo; }

	public @property int FirstSize() { return vbo.FirstSize; }

	this(OptimizeMode optimize_for, BufferMode mode) {
		this.optimize_for = optimize_for;
		this.buff_mode = mode;
		vao = new CVAO();
	}

	~this() {
		destroy(vao);
		destroy(vbo);
	}

	public void Bind() {
		vao.Bind();
	}

	public void Unbind() {
		vao.Unbind();
	}

	public void Draw(DrawType t = DrawType.LineStrip, int d_amnt = -1) {
		if (d_amnt == -1) d_amnt = vbo.FirstSize; 
		Bind();
		if (this.optimize_for == OptimizeMode.Mode2D) {
			//glDrawArrays is more optimal for 2D as there's less reuse of verticies.
			if (t == DrawType.TriangleStrip) {
				glDrawArrays(GL_TRIANGLE_STRIP, 0, d_amnt);
			} else if (t == DrawType.Triangles) {
				glDrawArrays(GL_TRIANGLES, 0, d_amnt);
			} else {
				glDrawArrays(GL_LINE_STRIP, 0, d_amnt);
			}
		} else {
			//glDrawElements is more optimal for 3D as 3D contains reuse of vertex structures, etc.
			if (t == DrawType.TriangleStrip) {
				glDrawElements(GL_TRIANGLE_STRIP, cast(int)ibo.Indices.length, GL_UNSIGNED_INT, ibo.Indices.ptr);
			} else if (t == DrawType.Triangles) {
				glDrawElements(GL_TRIANGLES, cast(int)ibo.Indices.length, GL_UNSIGNED_INT, ibo.Indices.ptr);
			} else {
				glDrawElements(GL_LINE_STRIP, cast(int)ibo.Indices.length, GL_UNSIGNED_INT, ibo.Indices.ptr);
			}
		}
		GLenum err = glGetError();
		while (err != GL_NO_ERROR) {
			throw new Error("GLSL error 0x" ~ format!"%04x"(err) ~ " check opengl documentation for more info.");
		}
		Unbind();
	}

	public void Clear() {
		destroy(vbo);
	}

	public void AddIndex(uint index) {
		if (ibo is null) {
			ibo = new CIBO();
		}
		ibo.indices.length++;
		ibo.Indices[$-1] = index;
	}

	public void AddShape(Shape s) {
		AddFloats(s.GetVertices());
	}

	public void AddFloats(float[][] verts) {
		if (vbo is null) {
			vbo = new CVBO(this.buff_mode);
		}
		vbo.AddVertices(verts);
	}

	public void Generate() {
		Bind();
		vbo.Generate();
		Unbind();
	}
}

class CVAO {

	private GLuint id;
	public @property uint Id() { return cast(uint)id; }

	this() {
		glGenVertexArrays(1, &id);
	}

	~this() {
		glDeleteVertexArrays(1, &id);
	}

	void Bind() {
		glBindVertexArray(id);
	}

	void Unbind() {
		glBindVertexArray(0);
	}
}

// Index Buffer Object contains indexes for the different models/etc.
class CIBO {
	private GLuint id;
	private BufferMode buff_mode;
	private uint[] indices;

	public @property uint Id() { return id; }

	public @property uint[] Indices() { return indices; }
	public @property void Indices(uint[] d) { indices = d; }

	this() {
		glGenBuffers(1, &id);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_DYNAMIC_DRAW);
		this.buff_mode = BufferMode.Dynamic;
	}

	this(uint[] indices) {
		this.indices = indices;
		glGenBuffers(1, &id);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);
		this.buff_mode = BufferMode.Static;
	}
}

// Vertex Buffer Object Verticies.
class CVBOVertices {
	public GLfloat[] Vertices;
	private int dimensions;

	public @property int Dimensions() { return this.dimensions; }

	public @property int Length() { return cast(int)Vertices.length; }

	public @property int VertexAmount() { return Length/Dimensions; }

	public this(float[][] verts) {
		this.dimensions = cast(int)verts[0].length;
		Add(verts);
	}

	public void Flush() {
		this.Vertices.length = 0;
	}

	public void Add(float[][] verts) {
		int c = cast(int)verts[0].length;
		if (this.dimensions != c) throw new Exception("Mismatching dimension lengths of data! " ~ c.text ~ " does not fit in " ~ this.dimensions.text);
		foreach(float[] fc; verts) {
			foreach (float f; fc) {
				Vertices.length++;
				Vertices[$-1] = cast(GLfloat)f;
			}
		}
	}

	public void Add(float[] verts) {
		int c = cast(int)verts.length;
		if (c % this.dimensions != 0) throw new Exception("Mismatching dimension lengths of data! " ~ c.text ~ " does not fit in " ~ this.dimensions.text ~ " dimensions.");
		foreach (float f; verts) {
			Vertices.length++;
			Vertices[$-1] = cast(GLfloat)f;
		}
	}
}

//Vertex Buffer Object, contains a buffer of vertices.
class CVBO {
	private GLuint[] ids;
	private BufferMode buff_mode;
	private CVBOVertices[] verts;

	public @property uint[] Ids() { return cast(uint[])ids; }
	public @property ref CVBOVertices[] Vertices() { return verts; }

	public @property int FirstSize() {
		return verts[0].VertexAmount;
	}

	public @property int Size() {
		int s = 0;
		foreach(CVBOVertices subverts; verts) {
			s += subverts.VertexAmount;
		}
		return s;
	}

	this(BufferMode mode) {
		this.buff_mode = mode;
	}

	~this() {
		Clear();
	}

	void AddVertices(float[][] verts) {
		this.verts.length++;
		this.verts[$-1] = new CVBOVertices(verts);
	}

	void Generate() {
		Generate(this.buff_mode);
	}

	void Generate(BufferMode buff) {
		ids.length = verts.length;
		glGenBuffers(cast(int)verts.length, ids.ptr);
		Logger.Debug("Generating {0} buffers @ {1}", verts.length, ids.ptr);
		for (int i = 0; i < verts.length; i++) {
			glBindBuffer(GL_ARRAY_BUFFER, ids[i]);
			if (buff == BufferMode.Static) glBufferData(GL_ARRAY_BUFFER, (verts[i].Length) * GLfloat.sizeof, verts[i].Vertices.ptr, GL_STATIC_DRAW);
			else glBufferData(GL_ARRAY_BUFFER, (verts[i].Length) * GLfloat.sizeof, verts[i].Vertices.ptr, GL_DYNAMIC_DRAW);
			glVertexAttribPointer(cast(GLuint)i, verts[i].Dimensions, GL_FLOAT, GL_FALSE, 0, null);
			Logger.Debug("Created attribs for {0}; i={1}; verts={2}; dims={3}", ids[i], i, verts[i].VertexAmount, verts[i].Dimensions);
			glEnableVertexAttribArray(i);
		}
	}

	void Update() {
		if (this.buff_mode == BufferMode.Dynamic) {
			for (int i = 0; i < verts.length; i++) {
				glBindBuffer(GL_ARRAY_BUFFER, ids[i]);
				glBufferData(GL_ARRAY_BUFFER, (verts[i].Length) * GLfloat.sizeof, verts[i].Vertices.ptr, GL_DYNAMIC_DRAW);
				glVertexAttribPointer(cast(GLuint)i, verts[i].Dimensions, GL_FLOAT, GL_FALSE, 0, null);
				glEnableVertexAttribArray(i);
				//Logger.Debug("Updated attribs for {0}; i={1}; verts={2}; dims={3}", ids[i], i, verts[i].VertexAmount, verts[i].Dimensions);
			}
		}
	}

	void Regenerate() {
		if (this.buff_mode == BufferMode.Dynamic) throw new Exception("Trying to regenerate a dynamic buffer! Try changing the data instead.");
		Regenerate(this.buff_mode);
	}

	void Regenerate(BufferMode buff) {
		Clear();
		Generate(buff);
	}

	void Flush() {
		if (this.buff_mode != BufferMode.Dynamic) throw new Exception("Trying to flush a static buffer! Try regenerating the data instead.");
		foreach (CVBOVertices v; verts) {
			v.Flush();
		}
	}

	void Clear() {
		for (int i = 0; i < ids.length; i++) {
			glDisableVertexAttribArray(i);
		}
		glDeleteBuffers(cast(int)verts.length, ids.ptr);
	}
}