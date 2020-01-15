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

	Vector2i baseCharSize;

public:
	/// Constructor
	this(TypeFace typeface) {
		this.typeface = typeface;
		PSize size = typeface.getAtlasSize();
		this.texture = new GlTexture2DImpl!(GL_RED, 1)(new TextureImg(cast(int)size.width, cast(int)size.height, typeface.getTexture()));

		// Gets the base character height of the character A
		baseCharSize = cast(Vector2i)MeasureCharacter('A');
	}

	/// Returns the texture for this sprite font
	Texture2D getTexture() {
		return cast(Texture2D)texture;
	}
	
	/// Indexer for glyph info
	GlyphInfo* opIndex(dchar c) {
		return typeface[c];
	}

	/// Measure the size of a string
	Vector2 MeasureString(string text) {
		int lines = 1;
		float currentLineLength = 0;
		Vector2 size = Vector2(0, 0);
		foreach(dchar c; text) {
			if (c == '\n') {
				lines++;
				currentLineLength = 0;
			}
			if (this[c] is null) continue;
			
			// Bitshift by 6 to make it be in pixels
			currentLineLength += (this[c].advance.x >> 6);

			if (currentLineLength > size.X) size.X = currentLineLength;
		}
		float height = lines*(baseCharSize.Y+(baseCharSize.Y/2));
		return Vector2(size.X, height-(baseCharSize.Y/2));
	}

	/// Measure the size of an individual character
	Vector2 MeasureCharacter(dchar c) {
		return Vector2((this[c].advance.x >> 6), this[c].bearing.y);
	}

	/**
		Returns the base size for the character 'A'
	*/
	@property Vector2i BaseCharSize() {
		return baseCharSize;
	}

	/**
		Gets the size of the sprite font texture atlas
	*/
	@property Vector2i TexSize() {
		return Vector2i(texture.Width, texture.Height);
	}
}