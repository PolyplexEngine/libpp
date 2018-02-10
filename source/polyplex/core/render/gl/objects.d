module polyplex.core.render.gl.buffers;
import derelict.sdl2.sdl;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.core.color;
import polyplex.core.render.shapes;
import polyplex.math;
import std.stdio;
import std.format;

enum DrawType {
	LineStrip,
	TriangleStrip
}

enum OptimizeMode {
	Mode3D,
	Mode2D
}

class RenderObject {
	private VAO vao;
	private VBO vbo;
	private IBO ibo;
	private OptimizeMode optimize_for;

	public @property int FirstSize() { return vbo.FirstSize; }

	this(OptimizeMode optimize_for) {
		this.optimize_for = optimize_for;
		vao = new VAO();
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

	public void Draw(DrawType t = DrawType.LineStrip) {
		Bind();
		if (this.optimize_for == OptimizeMode.Mode2D) {
			//glDrawArrays is more optimal for 2D as there's less reuse of verticies.
			if (t == DrawType.TriangleStrip) {
				glDrawArrays(GL_TRIANGLE_STRIP, 0, vbo.FirstSize);
			} else {
				glDrawArrays(GL_LINE_STRIP, 0, vbo.FirstSize);
			}
		} else {
			//glDrawElements is more optimal for 3D as 3D contains reuse of vertex structures, etc.
			if (t == DrawType.TriangleStrip) {
				glDrawElements(GL_TRIANGLE_STRIP, cast(int)ibo.Indices.length, GL_UNSIGNED_INT, ibo.Indices.ptr);
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
			ibo = new IBO();
		}
		ibo.indices.length++;
		ibo.Indices[$-1] = index;
	}

	public void AddShape(Shape s) {
		AddFloats(s.GetVertices());
	}

	public void AddFloats(float[][] verts) {
		if (vbo is null) {
			vbo = new VBO();
		}
		vbo.AddVertices(verts);
	}

	public void Generate() {
		Bind();
		vbo.Generate();
		Unbind();
	}
}

//Vertex Array Object contains state information to be sent to the GPU
class VAO {

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
class IBO {
	private GLuint id;
	private uint[] indices;

	public @property uint Id() { return id; }

	public @property uint[] Indices() { return indices; }
	public @property void Indices(uint[] d) { indices = d; }

	this() {
		glGenBuffers(1, &id);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);
	}
}

// Vertex Buffer Object Verticies.
class VBOVertices {
	public GLfloat[] Vertices;
	private int dimensions;

	public @property int Dimensions() { return this.dimensions; }

	public @property int Length() { return cast(int)Vertices.length; }

	public @property int VertexAmount() { return Length/Dimensions; }

	public this(float[][] verts) {
		this.dimensions = cast(int)verts[0].length;
		foreach(float[] fc; verts) {
			foreach (float f; fc) {
				Vertices.length++;
				Vertices[$-1] = cast(GLfloat)f;
			}
		}
		//writeln(Vertices);
	}
}

//Vertex Buffer Object, contains a buffer of vertices.
class VBO {
	VBOVertices[] verts;

	private GLuint[] ids;
	public @property uint[] Ids() { return cast(uint[])ids; }
	public @property ref VBOVertices[] Vertices() { return verts; }

	public @property int FirstSize() {
		return verts[0].VertexAmount;
	}

	public @property int Size() {
		int s = 0;
		foreach(VBOVertices subverts; verts) {
			s += subverts.VertexAmount;
		}
		return s;
	}

	this() {}

	~this() {
		Clear();
	}

	void AddVertices(float[][] verts) {
		this.verts.length++;
		this.verts[$-1] = new VBOVertices(verts);
	}

	void Generate() {
		ids.length = verts.length;
		glGenBuffers(cast(int)verts.length, ids.ptr);
		//writeln("Generating ", verts.length, " buffers, at ", ids.ptr);
		for (int i = 0; i < verts.length; i++) {
			glBindBuffer(GL_ARRAY_BUFFER, ids[i]);
			glBufferData(GL_ARRAY_BUFFER, (verts[i].Length) * GLfloat.sizeof, verts[i].Vertices.ptr, GL_STATIC_DRAW);
			glVertexAttribPointer(cast(GLuint)i, verts[i].Dimensions, GL_FLOAT, GL_FALSE, 0, null);
			//TODO: Logging
			//writeln("Created attribs for ", ids[i], ":", i, " containing array: ", verts[i].Vertices, " with ", verts[i].VertexAmount, " triangles and with ", verts[i].Dimensions, " dimensions.");
			glEnableVertexAttribArray(i);
		}
	}

	void Regenerate() {
		Clear();
		Generate();
	}

	void Clear() {
		for (int i = 0; i < ids.length; i++) {
			glDisableVertexAttribArray(i);
		}
		glDeleteBuffers(cast(int)verts.length, ids.ptr);
	}
}