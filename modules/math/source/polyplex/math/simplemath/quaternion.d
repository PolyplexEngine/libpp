module polyplex.math.simplemath.quaternion;
import polyplex.math.simplemath.matrix4x4;
import polyplex.math.simplemath.vectors;

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

	public void Reorient(Vector3 axis, float angle) {
		this.X = axis.X;
		this.Y = axis.Y;
		this.Z = axis.Z;
		this.W = angle;
	}

	public Vector3 ForwardDirection() {
		return Vector3(
			2 * (X*Z + W*Y), 
			2 * (Y*Z - W*X),
			1 - 2 * (X*X + Y*Y));
	}

	public Vector3 UpDirection() {
		return Vector3(
			2 * (X*Y + W*Z), 
			1 - 2 * (X*X + Z*Z),
			2 * (Y*Z - W*X));
	}

	public Vector3 LeftDirection() {
		return Vector3(
			1 - 2 * (Y*Y + Z*Z), 
			2 * (X*Y + W*Z),
			2 * (X*Z - W*Y));
	}

	public void Rotate(T)(Vector3 axis, T theta) {
		X = Mathf.Sin(cast(real)theta/2) * axis.X;
		Y = Mathf.Sin(cast(real)theta/2) * axis.Y;
		Z = Mathf.Sin(cast(real)theta/2) * axis.Z;
		W = Mathf.Cos(cast(real)theta/2);
	}

	public static Quaternion Rotated(T)(Vector3 axis, T theta) {
		Quaternion q;
		q.Rotate(axis, theta);
		return q;
	}

	/*public Vector3 Rotate(T)(Vector3 axis, T angle) {
		Vector3 vec;
		vec.X = X;
		vec.Y = Y;
		vec.Z = Z;

		float vd = 2.0f * vec.Dot(axis);
		Vector3 vdv = Vector3(vec.X * vd, vec.Y * vd, vec.Z * vd);

		float ad = W*W - vec.Dot(vec);
		Vector3 adv = Vector3(axis.X * ad, axis.Y * ad, axis.Z * ad);

		float vc = 2.0f * W;
		Vector3 vcv = vec.Cross(axis);
		vcv.X *= vc;
		vcv.Y *= vc;
		vcv.Z *= vc;

		return vdv * adv + vcv ;
	}*/

	public static Quaternion EulerToQuaternion(Vector3 euler) {
		Quaternion quat;

		// pitch
		double cp = Mathf.Cos(euler.X * 0.5);
		double sp = Mathf.Cos(euler.X * 0.5);

		// roll
		double cr = Mathf.Cos(euler.Y * 0.5);
		double sr = Mathf.Cos(euler.Y * 0.5);

		// yaw
		double cy = Mathf.Cos(euler.Z * 0.5);
		double sy = Mathf.Cos(euler.Z * 0.5);


		// convert to quaternion.
		quat.X = cy * sr * cp - sy * cr * sp;
		quat.Y = cy * cr * sp + sy * sr * cp;
		quat.Z = sy * cr * cp - cy * sr * sp;
		quat.W = cy * cr * cp + sy * sr * sp;
		return quat;
	}

	public static Quaternion FromMatrix(Matrix4x4 mat) {
		Quaternion qt = Quaternion.Identity;
		float tr = mat[0,0] + mat[1,1] + mat[2,2];

		if (tr > 0) {
			float S =  Mathf.Sqrt(tr+1.0) * 2;
			qt.X = (mat[2,1] - mat[1,2]) / S;
			qt.Y = (mat[0,2] - mat[2,0]) / S;
			qt.Z = (mat[1,0] - mat[0,1]) / S;
			qt.W = 0.25 * S;
			return qt;
		}

		if ((mat[0,0] > mat[1,1])&(mat[0,0] > mat[2,2])) {
			float S = Mathf.Sqrt(1.0 + mat[0,0] - mat[1,1] - mat[2,2]) * 2;
			qt.X = 0.25 * S;
			qt.Y = (mat[0,1] + mat[1,0]) / S;
			qt.Z = (mat[0,2] + mat[2,0]) / S;
			qt.W = (mat[2,1] - mat[1,2]) / S;
			return qt;
		}

		if (mat[1,1] > mat[2,2]) {
			float S = Mathf.Sqrt(1.0 + mat[1,1] - mat[0,0] - mat[2,2]) * 2;
			qt.X = (mat[0,1] + mat[1,0]) / S;
			qt.Y = 0.25 * S;
			qt.Z = (mat[1,2] - mat[2,1]) / S;
			qt.W = (mat[0,2] + mat[2,0]) / S;
			return qt;
		}

		float S = Mathf.Sqrt(1.0 + mat[2,2] - mat[0,0] - mat[1,1]) * 2;
		qt.X = (mat[0,2] + mat[2,0]) / S;
		qt.Y = (mat[1,2] - mat[2,1]) / S;
		qt.Z = 0.25 * S;
		qt.W = (mat[1,0] + mat[0,1]) / S;
		return qt;
	}

	// Binary actions.
	public @trusted nothrow Quaternion opBinary(string op, T2)(T2 other) if (is (T2 : Quaternion)) { 
		// Operation on these, (due to being smallest size) can be done faster this way.
		mixin(q{
			return Quaternion(
				this.X * other.W + this.Y * other.Z + this.Z * other.Y - this.W * other.X,
				-this.X * this.Z - this.Y * other.W + this.Z * other.X + this.W * other.Y,
				this.X * this.Y - this.Y * other.X + this.Z * other.W + this.W * other.Z,
				-this.X * this.X - this.Y * other.Y + this.Z * other.Z + this.W * other.W);
			}.Format(op)
		); 
	}

	public @trusted Quaternion Normalized() {
		import polyplex.math;
		double n = Mathf.Sqrt(X*X+Y*Y+Z*Z+W*W);
		return Quaternion(X/n, Y/n, Z/n, W/n);
	}

	public static Quaternion Identity() {
		return Quaternion(0f, 0f, 0f, 0f);
	}

	public string toString() {
		import pputils.strutils;
		return "<{0}, {1}, {2}, {3}>".Format(X, Y, Z, W);
	}
}
