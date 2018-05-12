module polyplex.core.render.gl.debug2d;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import polyplex.core.render.gl.objects;
import polyplex.core.render.camera;
import polyplex.core.color;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils;
import polyplex.math;
import polyplex.utils.mathutils;

import std.stdio;

private struct DebugVertexLayout {
	Vector2 ppPosition;
	Vector4 ppColor;
}

public class GlDebugging2D {
	private static GLShader shader;
	private static Matrix4x4 matrix;
	private static Camera2D cm;
	private static Renderer renderer;

	private static VertexBuffer!(DebugVertexLayout, Layout.Interleaved) buff;
	private static int matr_indx;

	public static void PrepDebugging(Renderer rend) {
		renderer = rend;
		buff = VertexBuffer!(DebugVertexLayout, Layout.Interleaved)([]);
		shader = new GLShader(new ShaderCode(import("debug.vsh"), import("debug.fsh"), ["ppPosition", "ppColor"]));
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

	public static void SetMatrix(Matrix4x4 camMatrix) {
		matrix = camMatrix;
	}

	public static void DrawDots(Vector2[] dot_points, Color color) {
		create_buffer_points(dot_points, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(renderer.Window.Width, renderer.Window.Height) * matrix);
		buff.Draw(0, DrawType.Points);
		buff.Unbind();
		shader.Detach();
	}

	public static void DrawLines(Vector2[] line_points, Color color) {
		if (line_points.length == 1) {
			DrawDots(line_points, color);
			return;
		}
		create_buffer_line(line_points, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(renderer.Window.Width, renderer.Window.Height) * matrix);
		buff.Draw(0, DrawType.Lines);
		buff.Unbind();
		shader.Detach();
	}

	public static void DrawRectangle(Rectangle rect, Color color = Color.White) {
		create_buffer(rect, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(renderer.Window.Width, renderer.Window.Height) * matrix);
		buff.Draw(0, DrawType.LineStrip);
		buff.Unbind();
		shader.Detach();
	}

	public static void DrawRectangleFilled(Rectangle rect, Color color = Color.White) {
		create_buffer(rect, color);
		buff.UpdateBuffer();
		shader.Attach();
		shader.SetUniform(matr_indx, cm.Project(renderer.Window.Width, renderer.Window.Height) * matrix);
		buff.Draw();
		shader.Detach();
		buff.Unbind();
	}
}