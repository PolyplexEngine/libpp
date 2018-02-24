module polyplex.core.content.gl.textures;
import polyplex.core.content.textures;
import derelict.opengl;
import derelict.opengl.gl;
import polyplex.utils.logging;
import polyplex.core.render;
import polyplex.core.render.gl.shader;


public class GlTexture2D : Texture2D {
	private GLuint id;

	this(TextureImg img) {
		Logger.Debug("{0}", img.Surface);
		super(img);

		int mode = GL_RGBA;

		if (img.Surface.format.BytesPerPixel == 3) {
			mode = GL_RGB;
		}

		glGenTextures(1, &id);
		Attach();

		glTexImage2D(GL_TEXTURE_2D, 0, mode, img.Surface.w, img.Surface.h, 0, mode, GL_UNSIGNED_BYTE, img.Surface.pixels);
		Detach();
	}

	~this() {
		glDeleteTextures(1, &id);
	}

	public override void Attach(Shader s = null) {
		if (s is null) {
			glBindTexture(GL_TEXTURE_2D, id);
			return;
		}
		if (!s.HasUniform("ppTexture")) throw new Exception("Texture2D requires ppTexture sampler2d uniform to attach to!");
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, id);
	}

	public override void Detach() {
		glBindTexture(GL_TEXTURE_2D, 0);
	}
}