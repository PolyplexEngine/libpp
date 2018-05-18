module polyplex.core.content.textures;
import derelict.sdl2.sdl;
import polyplex.core.color;
import polyplex.utils.logging;
import polyplex.utils.strutils;
import polyplex.core.content.gl;
import polyplex.core.render;
import polyplex.core.color;

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

public class Texture2DEffectors {
	/**
		Very simple upscaler, width and height gets scaled * <scale> parameter.
	*/
	public static Color[][] SimpleUpscale(Color[][] input, uint scale) {
		Color[][] c = input;

		Color[][] oc;
		Color[] lookup;

		oc.length = c.length*scale;
		for (int y = 0; y < oc.length; y++) {

			oc[y].length = c[y/scale].length*scale;
			lookup = c[y/scale][0..c[y/scale].length];

			int lx = 0;
			for (int x = 0; x < oc[y].length; x += scale) {
				for (int i = 0; i < scale; i++) {

					oc[y][x+i] = lookup[lx];
				}
				lx++;
			}
		}
		return oc;
	}

	public static Texture2D GetSubImage(string T = "Gl")(Texture2D from, int x, int y, int width, int height) {
		Color[][] from_pixels = from.Pixels;
		Color[][] to_pixels = [];

		int from_width = from.Width;
		int from_height = from.Height;

		// Set height.
		to_pixels.length = height;

		for (int py = 0; py < height; py++) {

			// Make sure that we don't add pixels not supposed to be there.
			if (y+py < 0) continue;
			if (y+py >= from_height) continue;

			// Set width.
			to_pixels[py].length = width;

			for (int px = 0; px < width; px++) {

				// Make sure that we don't add pixels not supposed to be there.
				if (x+px < 0) continue;
				if (x+px >= from_width) continue;

				// superimpose the pixels from (start x + current x) and (start y + current y).
				// (reverse cause arrays are reversed like that.)
				to_pixels[py][px] = from_pixels[y+py][x+px];
			}
		}
		mixin(q{return new {0}Texture2D(to_pixels);}.Format(T));
	}

	/**
		Superimposes <from> to texture <to> and returns the result.
	*/
	public static Texture2D Superimpose(string T = "Gl")(Texture2D from, Texture2D to, int x, int y) {
		Color[][] from_pixels = from.Pixels;
		Color[][] to_pixels = to.Pixels;

		int from_width = from.Width;
		int from_height = from.Height;

		int width = to.Width;
		int height = to.Height;

		for (int py = 0; py < from_height; py++) {

			// Make sure that we don't add pixels not supposed to be there.
			if (y+py < 0) continue;
			if (y+py >= height) continue;

			for (int px = 0; px < from_width; px++) {

				// Make sure that we don't add pixels not supposed to be there.
				if (x+px < 0) continue;
				if (x+px >= width) continue;

				// superimpose the pixels from (start x + current x) and (start y + current y).
				// (reverse cause arrays are reversed like that.)
				to_pixels[y+py][x+px] = to_pixels[y+py][x+px].PreMultAlphaBlend(from_pixels[py][px]);
			}
		}
		mixin(q{return new {0}Texture2D(to_pixels);}.Format(T));
	}
}

public abstract class Texture2D {
	protected TextureImg image;
	public @property int Width() { return image.Width; }
	public @property int Height() { return image.Height; }
	public @property Color[][] Pixels() {
		Logger.VerboseDebug("Returning image-pixel-color of dimensions {0}x{1}...", image.Width, image.Height);
		int i = 0;
		Color[][] o;
		o.length = image.Height;

		for (int y = 0; y < image.Height; y++) {
			o[y].length = image.Width;

			for (int x = 0; x < image.Width; x++) {

				o[y][x] = new Color(image.Pixels[i], image.Pixels[i+1], image.Pixels[i+2], image.Pixels[i+3]);
				i += 4;
			}
		}
		return o;
	}

	public @property void Pixels(Color[][] col) {
		ubyte[] colors = [];

		ulong h = col.length;
		if (h == 0) throw new Exception("Invalid height of 0");

		ulong w = col[0].length;
		if (w == 0) throw new Exception("Invalid width of 0");

		for (int y = 0; y < h; y++) {
			if (col[y].length != w) throw new Exception("Non square textures not supported!");
			for (int x = 0; x < w; x++) {
				colors ~= col[y][x].ColorBytes;
			}
		}

		this.image = new TextureImg(cast(int)w, cast(int)h, colors);
		this.rebuffer();
	}

	this(TextureImg input) {
		this.image = input;

		// Buffer in to the appropriate graphics API.
		rebuffer();
	}

	this(Color[][] colors) {

		// rebuffer is called from this, just apply the colors as a texture.
		this.Pixels(colors);
	}

	this() { }

	/**
		Binds the texture.	
	*/
	public abstract void Bind(int attach_pos = 0, Shader s = null);

	/**
		Unbinds the texture.	
	*/
	public abstract void Unbind();
	protected abstract void rebuffer();
}