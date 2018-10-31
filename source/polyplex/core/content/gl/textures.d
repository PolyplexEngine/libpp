module polyplex.core.content.gl.textures;
import polyplex.core.content.textures;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils.logging;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import polyplex.core.color;
import std.stdio;


public class GlTexture2D : Texture2D {
	private GLuint id;

	public override uint Id() {
		return id;
	}

	private static int MAX_TEX_UNITS = -1;

	this(TextureImg img) {
		Logger.VerboseDebug("Created GL Texture from image: {0}", img.InternalName);
		super(img);
	}

	this(Color[][] colors) {
		super(colors);
	}

	~this() {
		glDeleteTextures(1, &id);
	}

	/**
		Binds the texture.	
	*/
	public override void Bind(int attach_pos = 0, Shader s = null) {
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

	/**
		Unbinds the texture.
	*/
	public override void Unbind() {
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	protected override void rebuffer() {
		int mode = GL_RGBA;

		// Delete the current version of the texture in memory, if any.
		if (id != 0) glDeleteTextures(1, &id);

		// Reallow GL_RGB again in the future?
		/*if (img.Surface.format.BytesPerPixel == 3) {
			mode = GL_RGB;
		}*/

		// Generate a new texture over the old one, if any. Else just generate a new one and assign id.
		glGenTextures(1, &id);
		Bind();
		glTexImage2D(GL_TEXTURE_2D, 0, mode, image.Width, image.Height, 0, mode, GL_UNSIGNED_BYTE, image.Pixels.ptr);
		Unbind();

		// Set max texture units.
		if (MAX_TEX_UNITS == -1) {
			glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &MAX_TEX_UNITS);
			Logger.Info("Set max texture units to: {0}", MAX_TEX_UNITS);
		}
		Logger.VerboseDebug("Bound texture id {0}", id);
	}
}