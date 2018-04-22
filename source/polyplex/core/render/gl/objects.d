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
class VAO(T, Layout layout) {

	private GLuint id;
	public @property uint Id() { return cast(uint)id; }

	public VBO!(T, layout) ChildVBO;
	public IBO ChildIBO;

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
// Make sure valid types are in the struct
// TODO: Add type support for ints, and such.
enum ValidBufferType(T) = (is(T == float)) || (IsVector!T && is(T.Type == float));

struct VBO(T, Layout layout) {
	private GLuint[] gl_buffers;
	public T[] Data;

	this(T input) {
		this([input]);
	}

	this(T[] input) {
		this.Data = input;

		// Generate GL buffers.
		static if(layout == Layout.Grouped) {
			int struct_member_count = cast(int)__traits(allMembers, T).length;
			gl_buffers.length = struct_member_count;
			glGenBuffers(struct_member_count, gl_buffers.ptr);
		} else {
			gl_buffers.length = 1;
			glGenBuffers(1, gl_buffers.ptr);
		}
		set_attribute_pointers();
	}

	~this() {
		foreach(int iterator, string member; __traits(allMembers, T)) {
			glDisableVertexAttribArray(iterator);
		}
		glDeleteBuffers(cast(GLsizei)gl_buffers.length, gl_buffers.ptr);
	}

	private void set_attribute_pointers() {
		foreach(int iterator, string member; __traits(allMembers, T)) {
			// Use a mixin to get the offset values.
			mixin("int field_offset = T."~member~".offsetof;");
			mixin("int stride_size = T.sizeof;");
			mixin("int field_size = T."~member~".sizeof/4;");

			// Run the type test from above.
			mixin("static assert(ValidBufferType!(typeof(T."~member~")), \"Invalid buffer value <"~member~">, may only contain: float, vector2, vector3 and vector4s!\");");

			if (layout == Layout.Grouped) {
				Bind(iterator);
				glVertexAttribPointer(iterator, field_size, GL_FLOAT, GL_FALSE, 0, null);
				glEnableVertexAttribArray(iterator);
			} else {
				Bind();
				Logger.Debug("glVertexAttribPointer({0}, {1}, GL_FLOAT, GL_FALSE, {2}, {3})", iterator, field_size, stride_size, field_offset);
				glVertexAttribPointer(iterator, field_size, GL_FLOAT, GL_FALSE, stride_size, cast(GLvoid*)field_offset);
				Logger.Debug("glEnableVertexAttribArray({0})", iterator);
				glEnableVertexAttribArray(iterator);
			}
		}
	}

	public void Bind(int index = 0) {
		//Logger.Debug("glBindBuffer(GL_ARRAY_BUFFER, gl_buffers[{0}]) <ptr {1}>", index, gl_buffers[index]);
		glBindBuffer(GL_ARRAY_BUFFER, gl_buffers[index]);
	}

	public void Unbind() {
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	public void UpdateBuffer(int index = 0, BufferMode mode = BufferMode.Dynamic) {
		glBufferData(GL_ARRAY_BUFFER, Data.sizeof, Data.ptr, mode);
	}

	public void UpdateSubData(GLintptr offset, GLsizeiptr size) {
		glBufferSubData(GL_ARRAY_BUFFER, offset, size, cast(void*)Data.ptr);
	}

	public void Draw(int amount = 0) {
		if (amount == 0) glDrawArrays(GL_TRIANGLES, 0, cast(GLuint)this.Data.length);
		else glDrawArrays(GL_TRIANGLES, 0, amount);
	}
}

struct IBO {

}

/*
class IBO : BufferObject {
	this(Layout layout) {
		super(GL_ELEMENT_ARRAY_BUFFER, layout, null);
	}

	public override void Draw(int amount = 0) {
		throw new Exception("You can't draw an IBO, attach the IBO to a VBO instead.");
	}
}*/