module polyplex.core.render.gl.debug2d;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import polyplex.core.render.gl.objects;
import polyplex.core.render.camera;
import polyplex.core.color;
import bindbc.opengl;
import bindbc.opengl.gl;
import polyplex.utils;
import polyplex.math;
import polyplex.utils.mathutils;

import std.stdio;

private struct DebugVertexLayout {
	Vector2 ppPosition;
	Vector4 ppColor;
}

public class Debugging2D {
	private static Shader shader;
	private static Camera2D cm;

	private static VertexBuffer!(DebugVertexLayout, Layout.Interleaved) buff;
	private static int matr_indx;

	/**
		Prepares GlDebugging2D for rendering (backend, you don't need to run this yourself.)
	*/
	public static void PrepDebugging() {
		buff = VertexBuffer!(DebugVertexLayout, Layout.Interleaved)([]);
		shader = new Shader(new ShaderCode(import("debug.vert"), import("debug.frag")));
		matr_indx = shader.GetUniform("ppProjection");
		cm = new Camera2D(Vector2(0, 0));
		cm.Update();
	}

	private static void create_buffer(Rectangle rect, Color color) {
		buff.Data = [
			DebugVertexLayout(Vector2(rect.X, rect.Y), color.GLfColor()),
			DebugVertexLayout(Vector2(rect.X, rect.Y+rect.Height), color.GLfColor()),
			DebugVertexLayout(Vector2(rect.X+rect.Width, rect.Y+rect.Height), color.GLfColor()),
			DebugVertexLayout(Vector2(rect.X, rect.Y), color.GLfColor()),
			DebugVertexLayout(Vector2(rect.X+rect.Width, rect.Y), color.GLfColor()),
			DebugVertexLayout(Vector2(rect.X+rect.Width, rect.Y+rect.Height), color.GLfColor()),
		];
	}

	private static void create_buffer_line(Vector2[] lines, Color color) {
		buff.Data.length = lines.length*2;
		foreach(i; 1 .. lines.length) {
			buff.Data[(i*2)] = DebugVertexLayout(lines[i-1], color.GLfColor());
			buff.Data[(i*2)+1] = DebugVertexLayout(lines[i], color.GLfColor());
		}
	}

	private static void create_buffer_points(Vector2[] points, Color color) {
		buff.Data.length = points.length;
		foreach(i; 0 .. points.length) {
			buff.Data[i] = DebugVertexLayout(points[i], color.GLfColor());
		}
	}

	/**
		Resets the matrix for the debugging primitives.
	*/
	public static void ResetCamera() {
		cm = new Camera2D(Vector2(0, 0));
	}

	/**
		Sets the matrix for the debugging primitives.
	*/
	public static void SetCamera(Camera2D cam) {
		cm = cam;
	}

	/**
		Draws dots based on specified points and color.
	*/
	public static void DrawDots(Vector2[] dot_points, Color color) {
		create_buffer_points(dot_points, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * cm.Matrix);
		buff.Draw(0, DrawType.Points);
		buff.Unbind();
		shader.Detach();
	}

	/**
		Draws lines based on specified points and color.
	*/
	public static void DrawLines(Vector2[] line_points, Color color) {
		if (line_points.length == 1) {
			DrawDots(line_points, color);
			return;
		}
		create_buffer_line(line_points, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * cm.Matrix);
		buff.Draw(0, DrawType.Lines);
		buff.Unbind();
		shader.Detach();
	}

	/**
		Draws a line rectangle (2 triangles), with the specified color.
	*/
	public static void DrawRectangle(Rectangle rect, Color color = Color.White) {
		create_buffer(rect, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * cm.Matrix);
		buff.Draw(0, DrawType.LineStrip);
		buff.Unbind();
		shader.Detach();
	}

	/**
		Draws a filled rectangle, with the specified color.
	*/
	public static void DrawRectangleFilled(Rectangle rect, Color color = Color.White) {
		create_buffer(rect, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * cm.Matrix);
		buff.Draw();
		shader.Detach();
		buff.Unbind();
	}
}
