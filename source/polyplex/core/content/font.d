module polyplex.core.content.font;
import polyplex.core.content.textures;
import polyplex.core.content.gl.textures;
import polyplex.core.render.gl.gloo;
import ppc.types.font;
import polyplex.math;

public class SpriteFont {
private:
	GlTexture2DImpl!(GL_RED, 1) texture;
	TypeFace typeface;

public:
	this(TypeFace typeface) {
		this.typeface = typeface;
		PSize size = typeface.getAtlasSize();
		this.texture = new GlTexture2DImpl!(GL_RED, 1)(new TextureImg(cast(int)size.width, cast(int)size.height, typeface.getTexture()));
	}

	Texture2D getTexture() {
		return cast(Texture2D)texture;
	}
	
	GlyphInfo* opIndex(char c) {
		return typeface[c];
	}

	Vector2 MeasureString(string text) {
		Vector2 size = Vector2(0, 0);
		foreach(char c; text) {
			if (this[c] is null) continue;
			
			// Bitshift by 6 to make it be in pixels
			size.X += (this[c].advance.x >> 6);
			if (this[c].bearing.y > size.Y) size.Y = this[c].bearing.y;
		}
		return size;
	}
}