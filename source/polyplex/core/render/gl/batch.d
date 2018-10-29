module polyplex.core.render.gl.batch;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import polyplex.core.render.gl.objects;
import polyplex.core.render.camera;
import polyplex.core.content.textures;
import polyplex.core.color;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils;
import polyplex.math;
import polyplex.utils.mathutils;

import std.stdio;


private struct SprBatchData {
	Vector2 ppPosition;
	Vector2 ppTexcoord;
	Vector4 ppColor;
}

private alias SBatchVBO = VertexBuffer!(SprBatchData, Layout.Interleaved);

/**
	OpenGL implementation of a sprite batcher.
*/
public class GlSpriteBatch : SpriteBatch {
	private static string uniform_tex_name = "ppTexture";
	private static string uniform_prj_name = "ppProjection";
	private static string default_vert;
	private static string default_frag;
	private static Shader default_shader;
	private static Camera default_cam;
	private static bool has_init;

	private int size;
	private int queued;
	private int last_queued;

	private SprBatchData vector_data;
	private VertexBuffer!(SprBatchData, Layout.Interleaved) render_object;
	private VertexBuffer!(SprBatchData, Layout.Interleaved) render_object_2;

	private SpriteSorting sort_mode; 
	private Blending blend_state;
	private Sampling sample_state;
	private ProjectionState project_state;
	private Shader shader;
	private Matrix4x4 view_project;
	private Texture2D current_texture;
	private Texture2D current_texture_2;

	private RasterizerState raster_state;

	private bool has_begun = false;
	private bool swap = false;

	this(int size = 1000) {
		InitializeSpritebatch();
		this.size = size;
		render_object = VertexBuffer!(SprBatchData, Layout.Interleaved)([]);
		render_object_2 = VertexBuffer!(SprBatchData, Layout.Interleaved)([]);
	}

	public static void InitializeSpritebatch() {
		if (!has_init) has_init = !has_init;
		else return;

		default_vert = import("sprite_batch.vsh");
		default_frag = import("sprite_batch.fsh");

		default_shader = new GLShader(new ShaderCode(default_vert, default_frag, ["ppPosition", "ppTexcoord", "ppColor"]));
		default_cam = new Camera2D(Vector2(0, 0));
		default_cam.Update();
	}

	private void set_blend_state(Blending state) {
		if (state == Blending.Additive) {
			glBlendFunc (GL_SRC_COLOR, GL_ONE);
			glBlendFunc (GL_SRC_ALPHA, GL_ONE);
			return;
		}
		if (state == Blending.AlphaBlend) {
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			return;
		}
		if (state == Blending.NonPremultiplied) {
			glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			return;
		}
		glBlendFunc(GL_ONE, GL_ZERO);
		Logger.Warn("Some things are not implemented yet, noteably: DepthStencilStates, RasterizerStates and some SpriteSortModes.");
	}

	private void set_projection_state(ProjectionState state) {
		this.project_state = state;
	}

	private void set_raster_state(RasterizerState state) {
		if (state.ScissorTest) glEnable(GL_SCISSOR_TEST);
		if (state.MSAA) glEnable(GL_MULTISAMPLE);
		if (state.SlopeScaleBias > 0f) glEnable(GL_POLYGON_OFFSET_FILL);
	}

	private void reset_raster_state() {
		glDisable(GL_MULTISAMPLE);
		glDisable(GL_SCISSOR_TEST);
		glDisable(GL_POLYGON_OFFSET_FILL);
	}

	private void set_sampler_state(Sampling sampling) {
		switch (sampling) {
			case sampling.PointWrap:
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
				break;
			case sampling.PointClamp:
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
				break;
			case sampling.LinearWrap:
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
				break;
			case sampling.LinearClamp:
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
				break;
			default:
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
				break;
		}
	}

	private Matrix4x4 mult_matrices() {
		if (this.project_state == ProjectionState.Perspective)
			return this.default_cam.ProjectPerspective(Renderer.Window.ClientBounds.Width, 90f, Renderer.Window.ClientBounds.Height) * this.view_project;
		return this.default_cam.ProjectOrthographic(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * this.view_project;
	}

	public override void Begin() {
		Begin(SpriteSorting.Deferred, Blending.AlphaBlend, Sampling.LinearClamp, raster_state.Default, default_shader, default_cam);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	public override void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, RasterizerState raster_state, ProjectionState pstate, Shader s, Camera camera) {
		set_projection_state(pstate);
		Begin(sort_mode, blend_state, sample_state, raster_state, s, camera);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	public override void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, RasterizerState raster_state, Shader s, Camera camera) {
		Camera cam = camera;
		if (cam is null) cam = default_cam;
		cam.Update();
		Begin(sort_mode, blend_state, sample_state, raster_state, s, cam.Matrix);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	public override void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, RasterizerState raster_state, Shader s, Matrix4x4 matrix) {
		if (this.has_begun) throw new Exception("SpriteBatch.Begin called more than once! Remember to end spritebatch sessions before beginning new ones.");
		this.has_begun = true;
		this.sort_mode = sort_mode;
		this.sample_state = sample_state;
		this.blend_state = blend_state;
		this.view_project = matrix;
		this.shader = s;
		this.raster_state = raster_state;
		set_raster_state(this.raster_state);
		if (this.shader is null) this.shader = default_shader;
		this.current_texture = null;
		this.queued = 0;
	}

	/**
		Flush flushes the spritebatch, drawing whatever that has been batched to the screen.
		End() will automatically call this.
	*/
	public override void Flush() {
		render();
		last_queued = queued;
		queued = 0;
	}

	private void add_vertex(int offset, float x, float y, float r, float g, float b, float a, float u, float v) {
		//Logger.VerboseDebug("{0}, {1} == {2}", offset, (queued*6), (queued*6)+offset);
		if ((queued*6)+offset >= this.render_object.Data.length)
			this.render_object.Data.length++;
		this.render_object.Data[(queued*6)+offset].ppPosition = Vector2(x, y);
		this.render_object.Data[(queued*6)+offset].ppColor = Vector4(r, g, b, a);
		this.render_object.Data[(queued*6)+offset].ppTexcoord = Vector2(u, v);
	}

	private void check_flush(Texture2D texture) {
		if ((texture is null)) throw new Exception("Null value sprite. Please load a sprite before drawing it.");

		if (texture != current_texture || queued > size) {
			if (!(current_texture is null)) Flush();
			current_texture = texture;
		}
	}

	private void render() {
		// Buffer the data
		this.render_object.Bind();
		if ((queued*6) < last_queued) render_object.UpdateSubData(0, 0, (queued*6));
		else render_object.UpdateBuffer();

		// Draw current
		this.render_object.Bind();

		// Attach textures, set states, uniforms, etc.
		this.shader.Attach();
		if (!(current_texture is null)) current_texture.Bind(0, this.shader);
		set_sampler_state(sample_state);
		set_blend_state(blend_state);
		this.shader.SetUniform(this.shader.GetUniform(uniform_prj_name), mult_matrices());
		
		// Draw.
		render_object.Draw(queued*6);
	}

	/**
		Swaps the draw chain (double buffering)

		TODO: Add double buffering here.
	*/
	public override void SwapChain() {
		swap = !swap;
	}

	/**
		(Temporary) Sets the Scissor rectangle
	*/
	public void SetScissorRect(Rectangle rect) {
		glScissor(rect.X, Renderer.Window.ClientBounds.Height-rect.Y, rect.Width, rect.Height);
	}

	/**
		Draw draws a texture.
	*/
	public override void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) {
		Draw(texture, pos, cutout, 0f, Vector2(-1, -1), color, flip, zlayer);
	}

	/**
		Draw draws a texture.
	*/
	public override void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, float rotation, Vector2 Origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0) {
		check_flush(texture);
		float x1, y1;
		float x2, y2;
		float x3, y3;
		float x4, y4;

		static import std.math;
		float scaleX = cast(float)pos.Width/cast(float)texture.Width;
		float scaleY = cast(float)pos.Height/cast(float)texture.Height;
		float cx = Origin.X*scaleX;
		float cy = Origin.Y*scaleY;

		if (rotation != 0) {

			//top left
			float p1x = -cx;
			float p1y = -cy;

			//top right
			float p2x = pos.Width - cx;
			float p2y = -cy;

			//bottom right
			float p3x = pos.Width - cx;
			float p3y = pos.Height - cy;

			//bottom left
			float p4x = -cx;
			float p4y = pos.Height - cy;

			// Respect OffsetOrigin
			if (!OffsetOrigin) {
				cx = 0;
				cy = 0;
			}

			//Rotation sine and co-sine
			float cos = std.math.cos(rotation);
			float sin = std.math.sin(rotation);
			x1 = pos.X + (cos * p1x - sin * p1y) + cx;
			y1 = pos.Y + (sin * p1x + cos * p1y) + cy;

			x2 = pos.X + (cos * p2x - sin * p2y) + cx;
			y2 = pos.Y + (sin * p2x + cos * p2y) + cy;

			x3 = pos.X + (cos * p3x - sin * p3y) + cx;
			y3 = pos.Y + (sin * p3x + cos * p3y) + cy;

			x4 = pos.X + (cos * p4x - sin * p4y) + cx;
			y4 = pos.Y + (sin * p4x + cos * p4y) + cy;
		} else {
			// Respect OffsetOrigin
			if (OffsetOrigin) {
				cx = 0;
				cy = 0;
			}
			x1 = pos.X-cx;
			y1 = pos.Y-cy;

			x2 = pos.X+pos.Width-cx;
			y2 = pos.Y-cy;
			
			x3 = pos.X+pos.Width-cx;
			y3 = pos.Y+pos.Height-cy;

			x4 = pos.X-cx;
			y4 = pos.Y+pos.Height-cy;
		}
		// Remove any edges in spritesheets/atlases by cutting a tiiiiiny portion away
		float pxx = 0.2f/cast(float)texture.Width;
		float pxy = 0.2f/cast(float)texture.Height;

		float u = ((cutout.X)/cast(float)texture.Width)+pxx;
		float u2 = ((cutout.X+cutout.Width)/cast(float)texture.Width)-pxx;
		if ((flip&SpriteFlip.FlipVertical)>0) {
			float ux = u;
			u = u2;
			u2 = ux;
		}

		float v = ((cutout.Y)/cast(float)texture.Height)+pxy;
		float v2 = ((cutout.Y+cutout.Height)/cast(float)texture.Height)-pxy;
		if ((flip&SpriteFlip.FlipHorizontal)>0) {
			float vx = v;
			v = v2;
			v2 = vx;
		}

		add_vertex(0, x1, y1, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v); // TOP LEFT
		add_vertex(1, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(2, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		add_vertex(3, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(4, x3, y3, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v2); // BOTTOM RIGHT
		add_vertex(5, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		queued++;
	}

	/**
		Draw draws a texture.
		Rectangle pos will act like an AABB rectangle instead.
	*/
	public override void DrawAABB(Texture2D texture, Rectangle pos_top, Rectangle pos_bottom, Rectangle cutout, Vector2 Origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0) {
		check_flush(texture);
		float x1, y1;
		float x2, y2;
		float x3, y3;
		float x4, y4;

		static import std.math;
		x1 = pos_top.X;
		y1 = pos_top.Y;

		x2 = pos_top.Width;
		y2 = pos_top.Height;
		
		x3 = pos_bottom.Width;
		y3 = pos_bottom.Height;

		x4 = pos_bottom.X;
		y4 = pos_bottom.Y;
		float pxx = 0.2f/cast(float)texture.Width;
		float pxy = 0.2f/cast(float)texture.Height;

		float u = ((cutout.X)/cast(float)texture.Width)+pxx;
		float u2 = ((cutout.X+cutout.Width)/cast(float)texture.Width)-pxx;
		if ((flip&SpriteFlip.FlipVertical)>0) {
			float ux = u;
			u = u2;
			u2 = ux;
		}

		float v = ((cutout.Y)/cast(float)texture.Height)+pxy;
		float v2 = ((cutout.Y+cutout.Height)/cast(float)texture.Height)-pxy;
		if ((flip&SpriteFlip.FlipHorizontal)>0) {
			float vx = v;
			v = v2;
			v2 = vx;
		}

		add_vertex(0, x1, y1, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v); // TOP LEFT
		add_vertex(1, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(2, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		add_vertex(3, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(4, x3, y3, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v2); // BOTTOM RIGHT
		add_vertex(5, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		queued++;
	}

	/**
		End ends the sprite batching, allowing you to start a new batch.
	*/
	public override void End() {
		if (!has_begun) throw new Exception("SpriteBatch.Begin must be called before SpriteBatch.End.");
		has_begun = false;
		Flush();
		reset_raster_state();
	}
}
