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

/**
	OpenGL implementation of a sprite batcher.
*/
public class GlSpriteBatch : SpriteBatch {
	private static string uniform_tex_name = "ppTexture";
	private static string uniform_prj_name = "ppProjection";
	private static string attrib_color_name = "ppColor";
	private static string attrib_position_name = "ppPosition";
	private static string attrib_texcoord_name = "ppTexcoord";
	private static string default_vert;
	private static string default_frag;
	private static Shader default_shader;
	private static Camera default_cam;
	private static bool has_init;

	private int size;
	private int queued;

	private RenderObject render_object;

	private Renderer renderer;
	private SpriteSorting sort_mode; 
	private Blending blend_state;
	private Sampling sample_state;
	private Shader shader;
	private Matrix4x4 view_project;
	private Texture2D current_texture;
	private bool has_begun = false;

	this(Renderer renderer, int size = 1000) {
		this.renderer = renderer;
		InitializeSpritebatch();
		this.size = size;
		render_object = new RenderObject(OptimizeMode.Mode2D, BufferMode.Dynamic);
		//TODO: Improve VBO creation to not need to make dummy data.
		render_object.AddFloats([[0f, 0f, 0f]]);
		render_object.AddFloats([[0f, 0f]]);
		render_object.AddFloats([[0f, 0f, 0f, 0f]]);
		render_object.Generate();
		render_object.Vbo.Flush();
	}

	public static void InitializeSpritebatch() {
	if (!has_init) has_init = !has_init;
	else return;
default_vert = Format("#version 130
in vec3 {0};
in vec2 {1};
in vec4 {2};

uniform mat4 {3};

out vec4 exColor;
out vec2 exTexcoord;

void main(void) {
	exTexcoord = {1};
	exColor = {2};
	gl_Position = {3} * vec4({0}.xyz, 1.0);
}
", attrib_position_name, attrib_texcoord_name, attrib_color_name, uniform_prj_name);
default_frag = Format("#version 130

precision highp float;

uniform sampler2D {0};
in vec4 exColor;
in vec2 exTexcoord;
out vec4 outColor;

void main(void) {
	vec4 tex_col = texture2D({0}, exTexcoord);
	outColor = exColor * tex_col;
}
", uniform_tex_name);
	//Logger.Debug("DEFAULT_SHADER:\nVERT:\n{0}\nFRAG:\n{1}", default_vert, default_frag);

	default_shader = new GLShader(new ShaderCode(default_vert, default_frag, [attrib_position_name, attrib_texcoord_name, attrib_color_name]));
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
		return this.default_cam.Project(renderer.Window.Width, renderer.Window.Height) * this.view_project;
	}

	public override void Begin() {
		Begin(SpriteSorting.Deferred, Blending.AlphaBlend, Sampling.LinearClamp, default_shader, default_cam);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	public override void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_State, Shader s, Camera camera) {
		camera.Update();
		Begin(sort_mode, blend_state, sample_state, s, camera.Matrix);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	public override void Begin(SpriteSorting sort_mode, Blending blend_state, Sampling sample_state, Shader s, Matrix4x4 matrix) {
		if (this.has_begun) throw new Exception("SpriteBatch.Begin called more than once! Remember to end spritebatch sessions before beginning new ones.");
		this.has_begun = true;
		this.sort_mode = sort_mode;
		this.sample_state = sample_state;
		this.blend_state = blend_state;
		this.view_project = matrix;
		this.shader = s;
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
		render_object.Vbo.Flush();
		queued = 0;
	}

	private void add_vertex(float x, float y, float z, float r, float g, float b, float a, float u, float v) {
		render_object.Vbo.Vertices[0].Add([x, y, z]);
		render_object.Vbo.Vertices[1].Add([u, v]);
		render_object.Vbo.Vertices[2].Add([r, g, b, a]);
	}

	private void check_flush(Texture2D texture) {
		if ((texture is null)) throw new Exception("Null value sprite. Please load a sprite before drawing it.");

		if (texture != current_texture || queued > size) {
			if (!(current_texture is null)) Flush();
			current_texture = texture;
		}
	}

	private void render() {
		this.shader.Attach();
		if (!(current_texture is null)) current_texture.Attach(0, this.shader);
		set_sampler_state(sample_state);
		set_blend_state(blend_state);
		this.shader.SetUniform(this.shader.GetUniform(uniform_prj_name), mult_matrices());
		render_object.Vbo.Update();
		render_object.Draw(DrawType.Triangles);
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

		if (rotation != 0) {
			float scaleX = pos.Width/texture.Width;
			float scaleY = pos.Height/texture.Height;
			float cx = Origin.X*scaleX;
			float cy = Origin.Y*scaleY;

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
			x1 = pos.X;
			y1 = pos.Y;

			x2 = pos.X+pos.Width;
			y2 = pos.Y;
			
			x3 = pos.X+pos.Width;
			y3 = pos.Y+pos.Height;

			x4 = pos.X;
			y4 = pos.Y+pos.Height;
		}
		float u = cutout.X/cast(float)texture.Width;
		float u2 = (cutout.X+cutout.Width)/cast(float)texture.Width;
		if ((flip&SpriteFlip.FlipVertical)>0) {
			float ux = u;
			u = u2;
			u2 = ux;

		}

		float v = cutout.Y/cast(float)texture.Height;
		float v2 = (cutout.Y+cutout.Height)/cast(float)texture.Height;
		if ((flip&SpriteFlip.FlipHorizontal)>0) {
			float vx = v;
			v = v2;
			v2 = vx;
		}

		add_vertex(x1, y1, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v); // TOP LEFT
		add_vertex(x2, y2, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(x4, y4, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		add_vertex(x2, y2, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v), // TOP RIGHT
		add_vertex(x3, y3, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v2); // BOTTOM RIGHT
		add_vertex(x4, y4, zlayer, color.Rf(), color.Gf(), color.Bf(), color.Af(), u, v2); // BOTTOM LEFT
		queued++;
	}

	/**
		End ends the sprite batching, allowing you to start a new batch.
	*/
	public override void End() {
		if (!has_begun) throw new Exception("SpriteBatch.Begin must be called before SpriteBatch.End.");
		has_begun = false;
		Flush();
	}
}