module polyplex.core.color;
import polyplex.math;
import polyplex.utils.logging;
import polyplex.core.colors;

/**
	A class handling color and color blending
*/
public class Color {
public:
	mixin ColorList;

	union {
		struct {
			/// Red color
			int R;

			/// Green color
			int G;

			/// Blue color
			int B;

			/// Alpha transparency
			int A;
		}

		/// OpenGL friendly color
		Vector4i GLColor;
	}

	/// Constructor
	this(int r, int g, int b, int a) {
		R = Mathf.Clamp(r, 0, 255);
		G = Mathf.Clamp(g, 0, 255);
		B = Mathf.Clamp(b, 0, 255);
		A = Mathf.Clamp(a, 0, 255);
	}

	/// Constructor
	this(int r, int g, int b) {
		this(r, g, b, 255);
	}

	/// Constructor
	this(uint packed) {
		this((packed >> 24) & 0xff, (packed >> 16) & 0xff, (packed >> 8) & 0xff, packed & 0xff);
	}

	/// Float variant of red color
	@property float Rf() { return cast(float)R/255; }

	/// Float variant of green color
	@property float Gf() { return cast(float)G/255; }

	/// Float variant of blue color
	@property float Bf() { return cast(float)B/255; }

	/// Float variant of alpha transparency
	@property float Af() { return cast(float)A/255; }

	/// GL friendly float color
	@property Vector4 GLfColor() { return Vector4(Rf(), Gf(), Bf(), Af()); }
	
	/// Gets teh 
	@property ubyte[] ColorBytes() { return [cast(ubyte)R, cast(ubyte)G, cast(ubyte)B, cast(ubyte)A]; }

	/**
		Premultiplied alpha blending.
	*/
	Color PreMultAlphaBlend(Color other) {
		Color o = new Color(R, G, B, A);
		o.R = cast(int)(((other.Rf * other.Af) + (o.Rf * (1f - other.Af)))*255);
		o.G = cast(int)(((other.Gf * other.Af) + (o.Gf * (1f - other.Af)))*255);
		o.B = cast(int)(((other.Bf * other.Af) + (o.Bf * (1f - other.Af)))*255);
		o.A = 255;
		return o;
	}
}
