module polyplex.core.render.gl.objects;
import polyplex.core.render.shapes;
import polyplex.core.color;
import polyplex.math;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.opengl.gl;
import polyplex.utils.logging;
import polyplex.utils.strutils;
import std.stdio;
import std.conv;
import std.format;
import std.traits;

enum DrawType {
	LineStrip = GL_LINE_STRIP,
	TriangleStrip = GL_TRIANGLE_STRIP,
	Triangles = GL_TRIANGLES,
	Points = GL_POINTS,
	LineLoop = GL_LINE_LOOP,
	Lines = GL_LINES,
}

enum OptimizeMode {
	Mode3D,
	Mode2D
}

enum BufferMode {
	Static = GL_STATIC_DRAW,
	Dynamic = GL_DYNAMIC_DRAW
}


alias XBuffer = GLfloat[];

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
class XVertexArray(T, Layout layout) {

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
	XVertexArray!(T, layout) vao;
	private GLuint[] gl_buffers;
	public T[] Data;


	this(T input) {
		this([input]);
	}

	this(T[] input) {
		vao = new XVertexArray!(T, layout)();
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

			// Check if it's a valid type for the VBO buffer.
			mixin(q{ alias M = T.{0}; }.Format(member));
			static assert(ValidBufferType!(typeof(M)), "Invalid buffer value <{0}>, may only contain: float, vector2, vector3 and vector4s! (contains {1})".Format(member, typeof(M).stringof));

			if (layout == Layout.Seperated) {
				Bind(iterator+1);
				UpdateBuffer(iterator+1);
				glVertexAttribPointer(iterator, field_size, GL_FLOAT, GL_FALSE, 0, null);
				glEnableVertexAttribArray(iterator);
			} else {
				Bind();
				glVertexAttribPointer(cast(GLuint)iterator, field_size, GL_FLOAT, GL_FALSE, T.sizeof, field_t);
				glEnableVertexAttribArray(iterator);
			}
		}
	}

	public void Bind(int index = 0) {
		vao.Bind();
		glBindBuffer(GL_ARRAY_BUFFER, gl_buffers[index]);
	}

	public void Unbind() {
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		vao.Unbind();
	}

	public void UpdateBuffer(int index = 0, BufferMode mode = BufferMode.Dynamic) {
		Bind(index);
		glBufferData(GL_ARRAY_BUFFER, Data.length * T.sizeof, Data.ptr, mode);
		UpdateAttribPointers();
	}

	public void UpdateSubData(int index = 0, GLintptr offset = 0, GLsizeiptr size = 0) {
		Bind(index);
		glBufferSubData(GL_ARRAY_BUFFER, offset, T.sizeof*size, cast(void*)Data.ptr);
		UpdateAttribPointers();
	}

	public void Draw(int amount = 0, DrawType dt = DrawType.Triangles) {
		vao.Bind();
		if (amount == 0) glDrawArrays(dt, 0, cast(GLuint)this.Data.length);
		else glDrawArrays(dt, 0, amount);
		uint err = glGetError();
		import std.format;
		if (err != GL_NO_ERROR) {
			if (err == 0x500) throw new Exception("GLSL Invalid Enum Error ("~format!"%x"(err)~")!");
			if (err == 0x502) throw new Exception("GLSL Invalid Operation Error ("~format!"%x"(err)~")! (Are you sending the right types? Uniforms count!)");
			throw new Exception("Unhandled GLSL Exception.");
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
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, Indices.sizeof, Indices.ptr, mode);
	}

	public void UpdateSubData(int index = 0, GLintptr offset = 0, GLsizeiptr size = 0) {
		Bind();
		glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, cast(void*)Indices.ptr);
	}
}

public enum FBOTextureType {
	Color,
	Depth,
	Stencil,
	DepthStencil
}

/// WORK IN PROGRESS!

class FrameBuffer {
	// Internal managment value to make sure that the IsComplete function can revert to the userbound FBO.
	private static GLuint current_attch;

	private GLuint id;

	private GLuint[FBOTextureType] render_textures;

	private int width;
	private int height;

	public int Width() { return width; }
	public int Height() { return height; }

	public bool IsComplete() {
		Bind();
		bool status = (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
		glBindFramebuffer(GL_FRAMEBUFFER, current_attch);
		return status;
	}

	this() {
		glGenFramebuffers(1, &id);
	}

	~this() {
		glDeleteFramebuffers(1, &id);
	}

	public void SetTexture(FBOTextureType type) {
		if (render_textures[type] != 0) {
			// Delete previous texture.
			glBindTexture(GL_TEXTURE, render_textures[type]);
			glDeleteTextures(1, &render_textures[type]);
		}

		render_textures[type] = 0;
		glGenTextures(1, &render_textures[type]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  

	}

	public void Rebuild(int width, int height) {
		this.width = width;
		this.height = height;
	}

	public void Bind() {
		// Make sure IsComplete state can be reversed to this again.
		current_attch = id;
		glBindFramebuffer(GL_FRAMEBUFFER, id);
	}

	public void Unbind() {
		// Make sure IsComplete state can be reversed to this again.
		current_attch = id;
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
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
