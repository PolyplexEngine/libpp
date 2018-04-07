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


alias Buffer = GLfloat[];

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

class BufferInfo {
	string Name;
	int VBOIndex;
	int Dimensions;
	int Offset;
	int Size;

	this(string name, int index, int dimensions, int offset, int size) {
		this.Name = name;
		this.VBOIndex = index,
		this.Dimensions = dimensions;
		this.Offset = offset;
		this.Size = size;
	}
}

class BufferObject {
	private BufferInfo[string] buffer_map;
	private Layout layout;
	private int type;
	private int len;

	public GLuint[] Id;
	public Buffer[] Buffers = [];
	public VAO VertexArray;

	this(int type, Layout layout, VAO vao) {
		this.type = type;
		this.layout = layout;
		this.VertexArray = vao;
	}

	/**
		Generates <amount> buffers.
	*/
	public void GenBuffers(int amount) {
		if (Buffers.length == amount) return;

		Buffers.length = amount;
		Id.length = amount;
		glGenBuffers(amount, Id.ptr);
	}

	/**
		Binds the buffer of index <index>
	*/
	public void Bind(int index = 0) {
		glBindBuffer(this.type, Id[index]);
	}

	public int GetBuffMapId(string name) {
		foreach( BufferInfo inf; buffer_map ) {
			if (name == inf.Name) return inf.VBOIndex;
		}
		return -1;
	}

	public BufferInfo[string] ListAttributes() {
		return buffer_map;
	}

	public int Count() {
		return this.len;
	}

	public void EnableAttribute(int index) {
		glEnableVertexAttribArray(index);
	}

	public void SetAttributePointer(int index, int size, int stride = 0, int offset = 0) {
		if (offset == 0) glVertexAttribPointer(index, size, GL_FLOAT, GL_FALSE, stride, null);
		else glVertexAttribPointer(index, size, GL_FLOAT, GL_FALSE, stride, cast(void*)offset);
	}

	public void BufferData(int index, float[] data, BufferMode mode = BufferMode.Dynamic) {
		Buffers[index] = data;
		BufferData(index, cast(int)data.length, mode);
	}

	public void BufferData(int index, int size, BufferMode mode = BufferMode.Dynamic) {
		glBufferData(this.type, size * GLfloat.sizeof, Buffers[index].ptr, mode);
	}

	public void BufferSubData(int index, int offset, float[] data) {
		foreach( int i; 0 .. cast(int)data.length) {
			Buffers[index][offset+i] = data[i]; 
		}
		BufferSubdata(index, offset, cast(int)data.length);
	}

	public void BufferSubdata(int index, int offset, int size) {
		glBufferSubData(this.type, offset, size * GLfloat.sizeof, Buffers[index].ptr);
	}

	/**
		Supplies buffer data as a struct or class.
	*/
	public void BufferStruct(T)(T input_structs) {

		// Make sure valid types are in the struct
		// TODO: Add type support for ints, and such.
		enum ValidBufferType(T) = (is(T == float)) || (IsVector!T && is(T.Type == float));

		VertexArray.Bind();
		// Generate buffers if needed.
		int struct_member_count = cast(int)__traits(allMembers, T).length;	
		if (layout == Layout.Layered) {
			if (Buffers.length < struct_member_count) {
				GenBuffers(struct_member_count);
			}
		} else {
			if (Buffers.length == 0) {
				GenBuffers(1);
			}
		}

		Buffer[] pbfs = [];
		pbfs.length = struct_member_count;
		foreach(int iterator, string member; __traits(allMembers, T)) {
			// Get value at compile time.
			auto field = __traits(getMember, input_structs, member);

			// Run the type test froIbom above.
			static assert(isArray!(typeof(field)));
			static assert(ValidBufferType!(typeof(field[0])));
			
			// Add data to the buffer
			float[] buff = buffer_data(member, iterator, field);

			if (layout == Layout.Grouped) {
				pbfs[iterator] ~= buff;
			}

			// Specify amount of elements in the buffer object.
			this.len = cast(int)field.length;

			// Use this if/when runtime reflection might be added.
			// throw new Exception("Invalid buffer data type: " ~ typeid(field).text ~ "!");
		}
		/*if (layout != Layout.Layered) {
			if (layout == Layout.Grouped) {
				// TODO: Finish grouped rendering.
			}
			BufferData(0);
			EnableAttribute(0);
		}*/
		VertexArray.Unbind();
	}
	
	private float[] buffer_data(T)(string name, int index, T[] vec, BufferMode mode = BufferMode.Dynamic) if (IsVector!T) {
		float[] data = [];
		foreach(T v; vec) {
			data ~= v.data;
		}

		// Supply buffer mapping info.
		if (!(name in buffer_map) || mode == BufferMode.Dynamic) {
			BufferInfo inf;
			if (layout == Layout.Layered) {
				inf = new BufferInfo(name, index, vec[0].data.length, 0, 0);
			} else if (layout == Layout.Clustered) {
				inf = new BufferInfo(name, 0, cast(int)vec[0].data.length, cast(int)(Buffers[0].length * GLfloat.sizeof), 0);
			} else {
				inf = new BufferInfo(name, 0, cast(int)vec[0].data.length, cast(int)(Buffers[0].length * GLfloat.sizeof), cast(int)vec[0].data.length * GLfloat.sizeof);
			}
			buffer_map[name] = inf;
		}

		if (layout == Layout.Layered) {
			Bind(index);
			if (data.length <= Buffers[index].length) BufferSubData(index, 0, data);
			else BufferData(index, data, mode);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
		}

		if (layout == Layout.Clustered) {
			Bind(0);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
			Buffers[0] ~= data;
		}

		if (layout == Layout.Grouped) {
			Bind(0);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
		}

		if (layout == Layout.Layered) EnableAttribute(index);
		return data;
	}

	private float[] buffer_data(T:float[])(string name, int index, T flt, BufferMode mode = BufferMode.Dynamic) {
		float[] data = flt;

		// Supply buffer mapping info, if needed.
		if (!(name in buffer_map) || mode == BufferMode.Dynamic) {
			BufferInfo inf;
			if (layout == Layout.Layered) {
				inf = new BufferInfo(name, index, vec[0].data.length, 0, 0);
			} else if (layout == Layout.Clustered) {
				inf = new BufferInfo(name, 0, cast(int)vec[0].data.length, cast(int)(Buffers[0].length * GLfloat.sizeof), 0);
			} else {
				inf = new BufferInfo(name, 0, cast(int)vec[0].data.length, cast(int)(Buffers[0].length * GLfloat.sizeof), cast(int)vec[0].data.length * GLfloat.sizeof);
			}
			buffer_map[name] = inf;
		}

		if (layout == Layout.Layered) {
			Bind(index);
			if (data.length <= Buffers[index].length) BufferSubData(index, 0, data);
			else BufferData(index, data, mode);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
		}

		if (layout == Layout.Clustered) {
			Bind(0);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
			Buffers[0] ~= data;
		}

		if (layout == Layout.Grouped) {
			Bind(0);
			SetAttributePointer(index, buffer_map[name].Dimensions, buffer_map[name].Size, buffer_map[name].Offset);
		}

		if (layout == Layout.Layered) EnableAttribute(index);
		return data;
	}

	public abstract void Draw(int amount = 0);
}

class IBO : BufferObject {
	this(Layout layout) {
		super(GL_ELEMENT_ARRAY_BUFFER, layout, null);
	}

	public override void Draw() {
		throw new Exception("You can't draw an IBO, attach the IBO to a VBO instead.");
	}
}

class VBO : BufferObject {
	this(Layout layout) {
		super(GL_ARRAY_BUFFER, layout, new VAO());
	}

	public override void Draw(int amount = 0) {
		VertexArray.Bind();
		if (amount == 0) glDrawArrays(GL_TRIANGLES, 0, this.Count);
		else glDrawArrays(GL_TRIANGLES, 0, amount);
		VertexArray.Unbind();
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
		this.index_buffer.BufferData(0, data.data);
	}

	public override void Draw(int amount = 0) {
		glDrawElements(GL_TRIANGLES, this.Count, GL_FLOAT, null);
	}
}

class InstVBO : VBO {
	this(Layout layout) {
		super(layout);
	}

	public override void Draw(int amount = 0) {
		
	}
}

class InstIndxVBO : InstVBO {
	private IBO index_buffer;

	this(Layout layout) {
		super(layout);
		this.index_buffer = new IBO(layout);
	}

	public override void Draw(int amount = 0) {
		
	}
}

/*

*/