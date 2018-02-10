module polyplex.core.render.gl.batch;
import polyplex.core.render;
import polyplex.core.render.camera;
import polyplex.core.content.textures;
import polyplex.utils;
import polyplex.math;

public class GlSpriteBatch : SprBatch {
	private static string uniform_tex_name = "pp_u_tex";
	private static string uniform_prj_name = "pp_u_projection";
	private static string attrib_color_name = "pp_a_color";
	private static string attrib_position_name = "pp_a_position";
	private static string attrib_texcoord_name = "pp_a_texcoord";
	private static string default_vert;
	private static string default_frag;
	private static Camera2D default_cam;
	private static bool has_init;

	public static void InitializeSpritebatch() {
	if (!has_init) has_init = !has_init;
	else return;
default_vert = Format("
#version 130
uniform mat4 {0}; // pp_u_projection
attribute vec4 {1}; // pp_a_color
attribute vec2 {2}; // pp_a_texcoord
attribute vec2 {3}; // pp_a_position

varying vec2 pp_v_color;
varying vec2 pp_v_texcoord;

void main() {
	pp_v_color = {2}; // pp_a_texcoord
	pp_v_texcoord = {3};
	gl_Position = {0} * vec4({3}, 0.0, 1.0);
}

", uniform_prj_name, attrib_color_name, attrib_position_name, attrib_texcoord_name);
default_frag = Format("
#version 130
uniform sampler2D {0};
varying vec4 pp_v_color;
varying vec2 pp_v_texcoord;
out pp_out_color;

void main() {
	vec4 tex_col = texture2D({0}, pp_v_texcoords);
	pp_out_color = pp_v_color * tex_col;
}
", uniform_tex_name);

	default_cam = new Camera2D(Vector2(0, 0));
}

	public override void Begin(Camera2D camera = default_cam) {

	}

	/*public override void Draw(Texture2D texture, Rectangle pos, Rectangle cutout, float rotation = 0f, Vector2 Origin = Vector2(0, 0)) {

	}*/

	public override void End() {

	}
}