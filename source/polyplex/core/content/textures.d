module polyplex.core.content.textures;
import derelict.sdl2.image;
import derelict.sdl2.sdl;
import polyplex.core.color;
import polyplex.utils.logging;
import polyplex.core.content.gl;
import polyplex.core.render;

public class TextureImg {
	public SDL_Surface* Surface;

	/*public @property void* Pixels() { return surface.pixels; }
	public @property int Width() { return surface.w; }
	public @property int Height() { return surface.h; }*/

	//TODO: Contributor, make capability of adding own pixel data?
	//TODO: Contributor, add capability of editing pixels?

	/*this(Color[][] colordata) {
		this.width = cast(int)(colordata[0].length);
		this.height = cast(int)colordata.length;
		int i = 0;
		uint[][] pixels;
		for (int y = 0; y < colordata.length; y++) {
			for (int x = 0; x < colordata[y].length; x++) {
				pixels.length += 3;
				pixels[][i+0] = colordata[y][x].Red;
				pixels[][i+1] = colordata[y][x].Green;
				pixels[][i+2] = colordata[y][x].Blue;
				i++;
			}
		}
		this.surface = new SDL_Surface(SDL_D_SurfaceFlags.SDL_PREALLOC, SDL_PIXELFORMAT_RGBA8888, colordata.length, colordata[0].length, 1, cast(void*)pixels, null,)
		SDL_Surface()
	}*/

	this(SDL_Surface* input) {
		this.Surface = input;
	}

	~this() {
		SDL_FreeSurface(this.Surface);
	}
}


public abstract class Texture2D {
	protected TextureImg image;
	private int width;
	private int height;
	public @property int Width() { return width; }
	public @property int Height() { return height; }

	this(TextureImg input) {
		this.image = input;
		this.width = input.Surface.w;
		this.height = input.Surface.h;
	}

	this(int width, int height) {
		this.width = width;
		this.height = height;
	}

	public abstract void Attach(int attach_pos = 0, Shader s = null);
	public abstract void Detach();
}