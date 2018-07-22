module polyplex.math.simplemath.quaternion;

public struct Quaternion {
	private float[4] data;
	
	/**
		Creates a new Quaternion, in which initial values are X, Y, Z and W.
	*/
	public this(float x, float y, float z, float w) {
		data[0] = x;
		data[1] = y;
		data[2] = z;
		data[3] = w;
	}	
	
	/**
		Creates a new Quaternion, in which initial values are X, Y, Z and 0.
	*/
	public this(float x, float y, float z) {
		data[0] = x;
		data[1] = y;
		data[2] = z;
		data[3] = 0;
	}	

	/**
		Creates a new Quaternion, in which initial values are X, Y, 0 and 0.
	*/
	public this(float x, float y) {
		data[0] = x;
		data[1] = y;
		data[2] = 0;
		data[3] = 0;
	}

	/**
		Creates a new Quaternion, in which all initial values are X.
	*/
	public this(float x) {
		data[0] = x;
		data[1] = x;
		data[2] = x;
		data[3] = x;
	}

	/**
		The X component.	
	*/
	public float X() { return data[0]; }
	public void X(float value) { data[0] = value; }
		
	/**
		The Y component.	
	*/
	public float Y() { return data[1]; }
	public void Y(float value) { data[1] = value; }

	/**
		The Z component.	
	*/
	public float Z() { return data[2]; }
	public void Z(float value) { data[2] = value; }

	/**
		The W component.	
	*/
	public float W() { return data[3]; }
	public void W(float value) { data[3] = value; }

	public static Quaternion Identity() {
		return Quaternion(0f, 0f, 0f, 0f);
	}
}
