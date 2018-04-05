module polyplex.core.render.gl.objects;
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

//Vertex Array Object contains state information to be sent to the GPU
class VAO {

	private GLuint id;
	public @property uint Id() { return cast(uint)id; }

	public BufferObject[] Objects;

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

alias Buffer = float[];

/**
	Layout is the way data is layed out in a buffer object.
*/
enum Layout {
	/**
		A layout where each element is seperated out into multiple buffers.
		[XXX], [YYY], [ZZZ]
	*/
	Layered,

	/**
		A layout where each element is clustered into larger groups in one buffer.
		[XXXYYYZZZ]
	*/
	Clustered,

	/**
		A layout where each element is clustered into smaller groups in one buffer.
		[XYZXYZXYZ]
	*/
	Grouped
}


class BufferObject {
	private string[] buffer_map;
	private Layout layout;
	private int type;
	private int len;

	public GLuint[] Id;
	public Buffer[] Buffers = [];

	this(int type, Layout layout) {
		this.type = type;
		this.layout = layout;
	}

	/**
		Generates <amount> buffers.
	*/
	public void GenBuffers(int amount) {
		Buffers.length = amount;
		glGenBuffers(amount, Id.ptr);
	}

	/**
		Binds the buffer of index <index>
	*/
	public void Bind(int index = 0) {
		glBindBuffer(type, index);
	}

	public int GetBuffMapId(string name) {
		foreach( int i, string buff; buffer_map ) {
			if (buff == name) return i;
		}
		return -1;
	}

	public int Count() {
		return this.len;
	}

	/**
		Supplies buffer data as a struct or class.
	*/
	public void BufferData(T)(T input_structs) {

		// Make sure valid types are in the struct
		// TODO: Add type support for ints, and such.
		enum ValidBufferType(T) = (is(T == float)) || (IsVector!T && is(T.Type == float));

		foreach(int iterator, string member; __traits(allMembers, T)) {
			// Get value at compile time.
			auto field = __traits(getMember, input_structs, member);

			// Run the type test from above.
			static assert(isArray!(typeof(field)));
			static assert(ValidBufferType!(typeof(field[0])));

			queue_buffer_data(iterator, member);
			buffer_data(member, field);

			// TODO: add stride.
			specify_attrib_pointer(field, iterator, 0);

			// Specify amount of elements in the buffer object.
			this.len = cast(int)field.length;

			// Use this if/when runtime reflection might be added.
			// throw new Exception("Invalid buffer data type: " ~ typeid(field).text ~ "!");
		}
	}

	private void queue_buffer_data(int pos, string name) {
		if (layout == Layout.Layered) {
			if (Buffers.length <= pos) {
				Buffers.length = pos+1;
				Buffers[pos] = [];
			}
			if (buffer_map.length <= pos+1)
				buffer_map.length = pos+1;
			buffer_map[pos] = name;
		}

		Logger.Debug("[BufferObject] Attached attribute {0} to id {1}", name, pos);
	}

	private void specify_attrib_pointer(T:float)(T[] flt, int index, int stride) {
		specify_attrib_pointer(index, 1, stride);
	}

	private void specify_attrib_pointer(T) (T[] vec, int index, int stride) if (IsVector!T) {
		specify_attrib_pointer(index, vec[0].data.length, stride);
	}

	private void specify_attrib_pointer(int index, int size, int stride) {
		glVertexAttribPointer(index, size, GL_FLOAT, GL_FALSE, stride, null);
		glEnableVertexAttribArray(index);
	}

	private void buffer_data(T:float[])(string name, T val) {
		
		// Layered
		if (layout == Layout.Layered) {
			Buffers[GetBuffMapId(name)] ~= val;
			return;	
		}

		//Clustered
		if (layout == Layout.Clustered) {

			return;
		}

		//Grouped

	}

	private void buffer_data(T) (string name, T[] val) if (IsVector!T) {
		
		// Layered
		if (layout == Layout.Layered) {
			foreach(T vec; val) {
				Buffers[GetBuffMapId(name)] ~= vec.data;
			}
			return;	
		}

		//Clustered
		if (layout == Layout.Clustered) {

			return;
		}

		//Grouped

	}

	private void submit_data(int index, BufferMode mode = BufferMode.Dynamic) {
		glBufferData(this.type, Buffers[index].length * GLfloat.sizeof, &Buffers[index], mode);
	}

	public abstract void Draw();
}

class IBO : BufferObject {
	this(Layout layout) {
		super(GL_ELEMENT_ARRAY_BUFFER, layout);
	}

	public override void Draw() {
		throw new Exception("You can't draw an IBO, attach the IBO to a VBO instead.");
	}
}

class VBO : BufferObject {
	this(Layout layout) {
		super(GL_ARRAY_BUFFER, layout);
	}

	public override void Draw() {
		glDrawArrays(GL_TRIANGLES, 0, this.Count);
	}
}

class IndxVBO : VBO {
	private IBO index_buffer;

	this(Layout layout) {
		super(layout);
		this.index_buffer = new IBO(layout);
	}

	public void BufferIndices(float[] indices) {
		struct d {
			float[] data;
		}
		d data = d(indices);
		this.index_buffer.BufferData(data);
	}

	public override void Draw() {
		glDrawElements(GL_TRIANGLES, this.Count, GL_FLOAT, null);
	}
}

class InstVBO : VBO {
	this(Layout layout) {
		super(layout);
	}

	public override void Draw() {
		
	}
}

class InstIndxVBO : InstVBO {
	private IBO index_buffer;

	this(Layout layout) {
		super(layout);
		this.index_buffer = new IBO(layout);
	}

	public override void Draw() {
		
	}
}

unittest {
	struct t {
		Vector3[] tPosition;
		float[] tScale;
	}
	t tx = t([Vector3(1, 2, 3)], [4f]);

	BufferObject bo = new VBO(Layout.Layered);
	//                                                                               xx                                                                                           xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxcxxdbo.BufferData(tx);
}

/*

class RenderObject {
	private VAO vao;
	private VBO vbo;
	private IBO ibo;
	private OptimizeMode optimize_for;
	private BufferMode buff_mode;

	public @property VBO* Vbo() { return &vbo; }
	public @property VAO* Vao() { return &vao; }
	public @property IBO* Ibo() { return &ibo; }

	public @property int FirstSize() { return vbo.FirstSize; }

	this(OptimizeMode optimize_for, BufferMode mode) {
		this.optimize_for = optimize_for;
		this.buff_mode = mode;
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
			vbo = new VBO(this.buff_mode);
		}
		vbo.AddVertices(verts);
	}

	public void Generate() {
		Bind();
		vbo.Generate();
		Unbind();
	}
}

// Index Buffer Object contains indexes for the different models/etc.
class IBO {
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
class VBOVertices {
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
class VBO {
	private GLuint[] ids;
	private BufferMode buff_mode;
	private VBOVertices[] verts;

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

	this(BufferMode mode) {
		this.buff_mode = mode;
	}

	~this() {
		Clear();
	}

	void AddVertices(float[][] verts) {
		this.verts.length++;
		this.verts[$-1] = new VBOVertices(verts);
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
		foreach (VBOVertices v; verts) {
			v.Flush();
		}
	}

	void Clear() {
		for (int i = 0; i < ids.length; i++) {
			glDisableVertexAttribArray(i);
		}
		glDeleteBuffers(cast(int)verts.length, ids.ptr);
	}
}*/