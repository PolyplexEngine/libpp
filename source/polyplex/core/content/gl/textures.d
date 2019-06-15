module polyplex.core.content.gl.textures;
import polyplex.core.content.textures;
import polyplex.utils.logging;
import polyplex.core.render;
import polyplex.core.render.gl.gloo;
import polyplex.core.render.gl.shader;
import polyplex.core.color;
import std.stdio;


public class GlTexture2D : Texture2D {
private:
	Texture tex;

	static int MAX_TEX_UNITS = -1;
	
protected:
	override void rebuffer() {
		int mode = GL_RGBA;

		if (tex !is null) {
			UpdatePixelData(image.Pixels);
			return;
		}
		tex = new Texture();

		Bind();
		tex.Image2D(TextureType.Tex2D, 0, mode, image.Width, image.Height, 0, mode, GL_UNSIGNED_BYTE, image.Pixels.ptr);
		Unbind();

		// Set max texture units.
		if (MAX_TEX_UNITS == -1) {
			glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &MAX_TEX_UNITS);
			Logger.Info("Set max texture units to: {0}", MAX_TEX_UNITS);
		}
	}
public:
	override uint Id() {
		return tex.Id;
	}

	Texture GLTexture() {
		return tex;
	}

	this(TextureImg img) {
		Logger.VerboseDebug("Created GL Texture from image: {0}", img.InternalName);
		super(img);
	}

	this(Color[][] colors) {
		super(colors);
	}

	~this() {
		destroy(tex);
	}

	override void UpdatePixelData(ubyte[] data) {
		Bind();
		if (image !is null) image.SetPixels(data);
		glTexSubImage2D(TextureType.Tex2D, 0, 0, 0, image.Width, image.Height, GL_RGBA, GL_UNSIGNED_BYTE, data.ptr);
		Unbind();
	}

	/**
		Binds the texture.	
	*/
	override void Bind(int attachPos = 0, Shader s = null) {
		if (s is null) {
			tex.Bind(TextureType.Tex2D);
			return;
		}
		if (!s.HasUniform("ppTexture")) throw new Exception("Texture2D requires ppTexture sampler2d uniform to attach to!");
		if (attachPos > MAX_TEX_UNITS) attachPos = MAX_TEX_UNITS;
		if (attachPos < 0) attachPos = 0;

		tex.Bind(TextureType.Tex2D);
		tex.AttachTo(attachPos);
	}

	/**
		Unbinds the texture.
	*/
	override void Unbind() {
		tex.Unbind();
	}
}