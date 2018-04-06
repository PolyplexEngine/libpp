module polyplex.core.content.textures;
import derelict.sdl2.sdl;
import polyplex.core.color;
import polyplex.utils.logging;
import polyplex.core.content.gl;
import polyplex.core.render;

public class TextureImg {
	private int width;
	private int height;
	private ubyte[] pixels;

	public @property int Width() { return width; }
	public @property int Height() { return height; }
	public @property ubyte[] Pixels() { return pixels; }

	this(int width, int height, ubyte[] pixels) {
		this.width = width;
		this.height = height;
		this.pixels = pixels;
	}
}

public abstract class Texture2D {
	protected TextureImg image;
	public @property int Width() { return image.Width; }
	public @property int Height() { return image.Height; }

	this(TextureImg input) {
		this.image = input;
	}

	this() { }

	public abstract void Attach(int attach_pos = 0, Shader s = null);
	public abstract void Detach();
}