module polyplex.core.color;
import polyplex.math;

public class Colors {
	public static @property Color Red() { return new Color(255, 0, 0); }
	public static @property Color Green() { return new Color(0, 255, 0); }
	public static @property Color Blue() { return new Color(0, 0, 255); }
	public static @property Color Black() { return new Color(0, 0, 0);}
	//public static Color  
}

public class Color {
	private Vector4i coldata;
	public @property Vector4i GLColor() { return coldata; };

	public @property int Red() { return coldata.X; }
	public @property void Red(int r) { coldata.X = r; }

	public @property int Green() { return coldata.Y; }
	public @property void Green(int g) { coldata.Y = g; }

	public @property int Blue() { return coldata.Z; }
	public @property void Blue(int b) { coldata.Z = b; }

	public @property int Alpha() { return coldata.W; }
	public @property void Alpha(int a) { coldata.W = a; }

	public @property float Rf() { return coldata.X/255; }
	public @property float Gf() { return coldata.Y/255; }
	public @property float Bf() { return coldata.Z/255; }
	public @property float Af() { return coldata.W/255; }

	public @property Vector4 GLfColor() { return Vector4(Rf(), Gf(), Bf(), Af()); }

	this(int r, int g, int b, int a) {
		int tr = r;
		int tg = g;
		int tb = b;
		int ta = a;
		if (tr > 255) tr = 255;
		else if (tr < 0) tr = 0;

		if (tg > 255) tg = 255;
		else if (tg < 0) tg = 0;

		if (tb > 255) tb = 255;
		else if (tb < 0) tb = 0;

		if (ta > 255) ta = 255;
		else if (ta < 0) ta = 0;

		coldata = Vector4i(r, g, b, a);
	}

	this(int r, int g, int b) {
		this(r, g, b, 255);
	}

	this(uint packed) {
		this(packed >> 16, packed >> 8, packed, packed >> 24);
	}

}