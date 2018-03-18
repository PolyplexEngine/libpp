module polyplex.core.content.gl.textures;
import polyplex.core.content.textures;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils.logging;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import std.stdio;


public class GlTexture2D : Texture2D {
	private GLuint id;

	private static int MAX_TEX_UNITS = -1;

	this(TextureImg img) {
		super(img);

		int mode = GL_RGBA;

		// Reallow GL_RGB again in the future?
		/*if (img.Surface.format.BytesPerPixel == 3) {
			mode = GL_RGB;
		}*/
		glGenTextures(1, &id);
		Attach();
		glTexImage2D(GL_TEXTURE_2D, 0, mode, img.Width, img.Height, 0, mode, GL_UNSIGNED_BYTE, img.Pixels.ptr);
		Detach();

		if (MAX_TEX_UNITS == -1) {
			glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &MAX_TEX_UNITS);
			Logger.Info("Set max texture units to: {0}", MAX_TEX_UNITS);
		}
	}

	~this() {
		glDeleteTextures(1, &id);
	}

	public override void Attach(int attach_pos = 0, Shader s = null) {
		if (s is null) {
			glBindTexture(GL_TEXTURE_2D, id);
			return;
		}
		if (!s.HasUniform("ppTexture")) throw new Exception("Texture2D requires ppTexture sampler2d uniform to attach to!");
		int tpos = GL_TEXTURE0+attach_pos;

		if (tpos > MAX_TEX_UNITS) tpos = MAX_TEX_UNITS;
		if (tpos < GL_TEXTURE0) tpos = GL_TEXTURE0;
		glActiveTexture(tpos);
		glBindTexture(GL_TEXTURE_2D, id);
	}

	public override void Detach() {
		glBindTexture(GL_TEXTURE_2D, 0);
	}
}