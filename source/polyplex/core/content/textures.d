module polyplex.core.content.textures;
import derelict.sdl2.image;
import derelict.sdl2.sdl;
import polyplex.core.color;

public abstract class TextureImg {
	private uint[][] pixels;
	private int width;
	private int height;

	public @property uint[][] Pixels() { return pixels; }
	public @property int Width() { return width; }
	public @property int Height() { return height; }

	this(Color[][] colordata) {
		this.width = cast(int)(colordata[0].length);
		this.height = cast(int)colordata.length;
		int i = 0;
		for (int y = 0; y < colordata.length; y++) {
			for (int x = 0; x < colordata[y].length; x++) {
				this.pixels.length++;
				this.pixels[i].length += 3;
				this.pixels[i][0] = colordata[y][x].Red;
				this.pixels[i][1] = colordata[y][x].Green;
				this.pixels[i][2] = colordata[y][x].Blue;
				i++;
			}
		}
	}

	this(SDL_Surface* input) {
		//this.pixels = input.pixels;
		this.width = input.w;
		this.height = input.h;
	}
}

public abstract class Texture {
	protected TextureImg image;


	this(TextureImg input) {
		this.image = input;
	}
}

public class Texture2D : Texture {
	private int width;
	private int height;
	public @property int Width() { return width; }
	public @property int Height() { return height; }

	this(int width, int height) {
		this.width = width;
		this.height = height;
		super(null);
	}

	this(TextureImg input) {
		super(input);
	}
}

public class Texture3D : Texture {

	this(TextureImg input) {
		super(input);
	}
}