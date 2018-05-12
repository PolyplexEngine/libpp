module polyplex.core.render.gl.objects;
import polyplex.core.render.shapes;
import polyplex.core.color;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils.logging;
import polyplex.utils.strutils;
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
	Seperated,

	/**
		A layout where each element is clustered into larger groups in one buffer.
		[XXXYYYZZZ]
	*/
	Batched,

	/**
		A layout where each element is clustered into smaller groups in one buffer.
		[XYZXYZXYZ]
	*/
	Interleaved
}

//Vertex Array Object contains state information to be sent to the GPU
class VertexArray(T, Layout layout) {

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

// Make sure valid types are in the struct
// TODO: Add type support for ints, and such.
enum ValidBufferType(T) = (is(T == float)) || (IsVector!T && is(T.Type == float));

struct VertexBuffer(T, Layout layout) {
	VertexArray!(T, layout) vao;
	private GLuint[] gl_buffers;
	public T[] Data;


	this(T input) {
		this([input]);
	}

	this(T[] input) {
		vao = new VertexArray!(T, layout)();
		this.Data = input;

		vao.Bind();

		// Generate GL buffers.
		static if(layout == Layout.Seperated) {
			int struct_member_count = cast(int)__traits(allMembers, T).length;
			gl_buffers.length = struct_member_count;
			glGenBuffers(struct_member_count, gl_buffers.ptr);
		} else {
			gl_buffers.length = 1;
			glGenBuffers(1, gl_buffers.ptr);
			UpdateBuffer();
		}
	}

	~this() {
		foreach(int iterator, string member; __traits(allMembers, T)) {
			glDisableVertexAttribArray(iterator);
		}
		glDeleteBuffers(cast(GLsizei)gl_buffers.length, gl_buffers.ptr);
		destroy(vao);
	}

	public void UpdateAttribPointers() {
		if (Data.length == 0) return;
		foreach(int iterator, string member; __traits(allMembers, T)) {
			// Use a mixin to get the offset values.
			mixin(q{int field_size = T.{0}.sizeof/4;}.Format(member));
			mixin(q{void* field_t = cast(void*)T.{0}.offsetof;}.Format(member));

			Logger.VerboseDebug("{0}", T.sizeof);

			// Check if it's a valid type for the VBO buffer.
			mixin(q{ alias M = T.{0}; }.Format(member));
			static assert(ValidBufferType!(typeof(M)), "Invalid buffer value <{0}>, may only contain: float, vector2, vector3 and vector4s!".Format(member));

			if (layout == Layout.Seperated) {
				Bind(iterator+1);
				UpdateBuffer(iterator+1);
				glVertexAttribPointer(iterator, field_size, GL_FLOAT, GL_FALSE, 0, null);
				glEnableVertexAttribArray(iterator);
			} else {
				Bind();
				Logger.VerboseDebug("glVertexAttribPointer({0}, {1}, GL_FLOAT, GL_FALSE, {2}, {3})", iterator, field_size, T.sizeof, field_t);
				glVertexAttribPointer(cast(GLuint)iterator, field_size, GL_FLOAT, GL_FALSE, T.sizeof, field_t);
				Logger.VerboseDebug("glEnableVertexAttribArray({0})", iterator);
				glEnableVertexAttribArray(iterator);
			}
		}
	}

	public void Bind(int index = 0) {
		Logger.VerboseDebug("glBindBuffer(GL_ARRAY_BUFFER, gl_buffers[{0}]) <ptr {1}>", index, gl_buffers[index]);
		vao.Bind();
		glBindBuffer(GL_ARRAY_BUFFER, gl_buffers[index]);
	}

	public void Unbind() {
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		vao.Unbind();
	}

	public void UpdateBuffer(int index = 0, BufferMode mode = BufferMode.Dynamic) {
		Bind(index);
		Logger.VerboseDebug("glBufferData(GL_ARRAY_BUFFER, {0}, {1}, {2})", Data.sizeof, Data.ptr, mode);
		glBufferData(GL_ARRAY_BUFFER, Data.length * T.sizeof, Data.ptr, mode);
		UpdateAttribPointers();
	}

	public void UpdateSubData(int index = 0, GLintptr offset = 0, GLsizeiptr size = 0) {
		Bind(index);
		glBufferSubData(GL_ARRAY_BUFFER, offset, T.sizeof*size, cast(void*)Data.ptr);
		UpdateAttribPointers();
	}

	public void Draw(int amount = 0) {
		vao.Bind();
		if (amount == 0) glDrawArrays(GL_TRIANGLES, 0, cast(GLuint)this.Data.length);
		else glDrawArrays(GL_TRIANGLES, 0, amount);
		uint err = glGetError();
		if (err != GL_NO_ERROR) {
			Logger.Debug("{0}", err);
		}
	}
}

struct IndexBuffer {
	public GLuint[] Indices;
	public GLuint Id;

	this(GLuint[] indices) {
		glGenBuffers(1, &Id);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, Id);
		this.Indices = indices;
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.sizeof, indices.ptr, GL_DYNAMIC_DRAW);
	}

	public void Bind() {
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, Id);
	}

	public void Unbind() {
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}

	public void UpdateBuffer(int index = 0, BufferMode mode = BufferMode.Dynamic) {
		Bind();
		Logger.VerboseDebug("glBufferData(GL_ARRAY_BUFFER, {0}, {1}, {2})", Indices.sizeof, Indices.ptr, mode);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, Indices.sizeof, Indices.ptr, mode);
	}

	public void UpdateSubData(int index = 0, GLintptr offset = 0, GLsizeiptr size = 0) {
		Bind();
		glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, cast(void*)Indices.ptr);
	}
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