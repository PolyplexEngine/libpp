module polyplex.math.vector;

class Vector {
	public abstract @property float[] GlValues();
}

class Vector2 : Vector {
	public float X;
	public float Y;

	public static @property Vector2 Zero() { return new Vector2(0, 0); }
	public override @property float[] GlValues() { return [X, Y]; }

	this(float x, float y) {
		this.X = x;
		this.Y = y;
	}

}

class Vector3 : Vector {
	public float X;
	public float Y;
	public float Z;

	public static @property Vector3 Zero() { return new Vector3(0, 0, 0); }
	public override @property float[] GlValues() { return [X, Y, Z]; }

	this(float x, float y, float z) {
		this.X = x;
		this.Y = y;
		this.Z = z;
	}

}

class Vector4 : Vector {
	public float X;
	public float Y;
	public float Z;
	public float W;

	public static @property Vector4 Zero() { return new Vector4(0, 0, 0, 0); }
	public override @property float[] GlValues() { return [X, Y, Z, W]; }

	this(float x, float y, float z, float w) {
		this.X = x;
		this.Y = y;
		this.Z = z;
		this.W = w;
	}

}