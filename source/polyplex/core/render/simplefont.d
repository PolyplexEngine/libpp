module polyplex.core.render.simplefont;
import polyplex.utils.random;
import polyplex.core;
import polyplex.math;
import polyplex.core.render.gl.shader;
import std.stdio;

public class SpriteFontSimple {
	private Texture2D font_texture;
	private SpriteBatch sprite_batch;
	private ContentManager manager;
	private Vector2i font_split;
	private static Random rng;

	this(SpriteBatch batcher, ContentManager man, string font_name, Vector2i font_split = Vector2i(10, 10)) {
		this.sprite_batch = batcher;
		this.manager = man;
		this.font_texture = manager.Load!Texture2D(font_name);
		this.font_split = font_split;
		if (rng is null) rng = new Random();
	}

	this(ContentManager man, string font_name, Vector2i font_split = Vector2i(10, 10)) {
		this.manager = man;
		this.font_texture = manager.Load!Texture2D(font_name);
		this.font_split = font_split;
		if (rng is null) rng = new Random();
	}

	private Vector2 get_glyph(char chr) {
		float chr_f = cast(float)chr-33;
		return Vector2(chr_f%font_split.X, (chr_f/font_split.Y)%font_split.Y);
	}

	public Vector2 MeasureString(string text, float scale = 1f) {
		Vector2 cursor_pos = Vector2(0, ((font_texture.Height/font_split.Y) - 2f)*scale);
		foreach(char c; text) {
			Vector2 glyph_pos = get_glyph(c);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
			}
		}
		return cursor_pos;
	}

	public void DrawString(string text, Vector2 position, float scale = 1f, Color color = Color.White, GameTimes game_time = null, bool shake = false, float intensity = 1f) {
		Vector2 cursor_pos = position;
		foreach(char c; text) {
			Vector2 shake_offset = Vector2(0, 0);
			if (shake) {
				shake_offset = Vector2(Mathf.Sin(game_time.TotalTime.Seconds+cursor_pos.X+rng.Next())*intensity, Mathf.Cos(game_time.TotalTime.Seconds+cursor_pos.Y+rng.Next())*intensity);
			}
			Vector2 glyph_pos = get_glyph(c);
			if (c != ' ' && c != '\n')
			sprite_batch.Draw(
				font_texture, 
				new Rectangle(
					cast(int)(cursor_pos.X+shake_offset.X), 
					cast(int)(cursor_pos.Y+shake_offset.Y), 
					cast(int)((font_texture.Width/font_split.X)*scale), 
					cast(int)((font_texture.Height/font_split.Y)*scale)),
				new Rectangle(
					cast(int)glyph_pos.X*(font_texture.Width/font_split.X), 
					cast(int)glyph_pos.Y*(font_texture.Height/font_split.Y), 
					font_texture.Width/font_split.X, 
					font_texture.Height/font_split.Y),
				color);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
				cursor_pos = Vector2(position.X, cursor_pos.Y);
			}
		}
	}

	public void DrawString(SpriteBatch sprite_batch, string text, Vector2 position, float scale = 1f, Color color = Color.White, GameTimes game_time = null, bool shake = false, float intensity = 1f) {
		Vector2 cursor_pos = position;
		foreach(char c; text) {
			Vector2 shake_offset = Vector2(0, 0);
			if (shake) {
				shake_offset = Vector2(Mathf.Sin(game_time.TotalTime.Seconds+cursor_pos.X+rng.Next())*intensity, Mathf.Cos(game_time.TotalTime.Seconds+cursor_pos.Y+rng.Next())*intensity);
			}
			Vector2 glyph_pos = get_glyph(c);
			if (c != ' ' && c != '\n')
			sprite_batch.Draw(
				font_texture, 
				new Rectangle(
					cast(int)(cursor_pos.X+shake_offset.X), 
					cast(int)(cursor_pos.Y+shake_offset.Y), 
					cast(int)((font_texture.Width/font_split.X)*scale), 
					cast(int)((font_texture.Height/font_split.Y)*scale)),
				new Rectangle(
					cast(int)glyph_pos.X*(font_texture.Width/font_split.X), 
					cast(int)glyph_pos.Y*(font_texture.Height/font_split.Y), 
					font_texture.Width/font_split.X, 
					font_texture.Height/font_split.Y),
				color);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
				cursor_pos = Vector2(position.X, cursor_pos.Y);
			}
		}
	}
}