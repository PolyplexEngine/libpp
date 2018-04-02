module polyplex.math.quaternion;
import polyplex.math.vector;
static import Mathf = polyplex.math.mathf;

import std.traits;

alias Quaternion = QuaternionT!float;
/**
  A quaternion is a way of representing a rotation in three dimensions by
    storing a rotation and an angle. It properly forms a topological 3-sphere,
    which allows it to avoid the gimbal lock that plagues the more
    human-readable euler angle.
  Read more here:
  https://euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/geometric/orthogonal
**/
struct QuaternionT(T) if (__traits(isFloating, T)) {
	/// Holds rotation (xyz) and angle (w)
	public Vector4T!T data;

  public immutable alias Type = T;

	// convert to string Q<x, y, z, w>
	public alias ToString = toString;
	public string toString() {
		return "Q" ~ data.toString();
	}

	// -- Accessors, just call data vector
	public @property auto opDispatch(string swizzle_list, U=void)() pure const nothrow {
		return data.opDispatch!(swizzle_list);
	}
	public @property auto opDispatch(string swizzle_list, U)(U x) pure nothrow {
		return data.opDispatch!(swizzle_list, U)(x);
	}
	unittest {
		assert(__traits(compiles, QuaternionT!T(float3(0.2f), 0.2f).xy));
		assert(QuaternionT!T(Vector4T!T(4)).xwz == Vector3T!T(4));
	}

	/// Constructs a quaternion from a vector
	public this(Vector4T!T vec) pure nothrow { data = vec; }

	/// Constructs a quaternion from another quaternion
	public this(QuaternionT!T quat) pure nothrow { data = quat.data; }

	/// Constructs a quaternion from an axis and an angle theta
	public this(Vector3T!T axis, T theta) pure nothrow {
		// adjust axis and theta
		axis = axis.Normalize();
		theta = theta/cast(T)2;
		T sin_theta = Mathf.Sin(theta);
		// Set data
		data.w = Mathf.Cos(theta);
		data.x = sin_theta*axis.x;
		data.y = sin_theta*axis.x;
		data.z = sin_theta*axis.x;
	}
	unittest {
		assert(__traits(compiles, QuaternionT!T(Vector3T!T(0.3f), 0.5f)));
	}

	/// Constructs identity of a quaternion
	public static QuaternionT!T Identity() pure nothrow {
		QuaternionT!T q;
		q.x = q.y = q.z = 0;
		q.w = 1;
		return q;
	}

	/// Constructs a quaternion from euler angle
	public static QuaternionT!T ToQuaternion(T pitch, T roll, T yaw) pure nothrow {
		QuaternionT!T q;
		// adjust angles
		pitch *= cast(T)0.5f;
		roll *= cast(T)0.5f;
		yaw *= cast(T)0.5f;

		T cy = Mathf.Cos(yaw), sy = Mathf.Sin(yaw);
		T cr = Mathf.Cos(roll), sr = Mathf.Sin(roll);
		T cp = Mathf.Cos(pitch), sp = Mathf.Sin(pitch);

		q.w = cy*cr*cp + sy*sr*sp;
		q.x = cy*sr*cp - sy*cr*sp;
		q.y = cy*cr*sp + sy*sr*cp;
		q.z = sy*cr*cp - cy*sr*sp;

		return q;
	}

	/// Constructs a quaternion from euler angle vector
	public static QuaternionT!T ToQuaternion(Vector3T!T vec) pure nothrow {
		return ToQuaternion(vec.x, vec.y, vec.z);
	}
	
	unittest {
		assert(__traits(compiles, ToQuaternion(Vector3T!T(0.2f))));
		assert(__traits(compiles, ToQuaternion(0.2f, 0.5f, 0.6f)));
	}

	/// Returns the euler angle equivalent of this quaternion, in the form of
	///   <roll, pitch, yaw>
	public Vector3T!T ToEulerAngle() pure const nothrow {
		Vector3T!T euler;
		QuaternionT!T q = this;

		// calculate roll
		T sinr = 2 * (q.w*q.x + q.y*q.z);
		T cosr = 1 - 2*(q.x*q.x + q.y*q.y);
		euler.X = Mathf.ATan2(sinr, cosr);

		// calculate pitch
		T sinp = Mathf.Clamp(2*(q.w*q.y - q.z*q.x), cast(T)-1, cast(T)1);
		euler.Y = Mathf.ASin(sinp);

		// calculate yaw
		T siny = 2 * (q.w*q.z + q.x*q.y);
		T cosy = 1 - 2*(q.y*q.y + q.z*q.z);
		euler.Z = Mathf.ATan2(siny, cosy);

		return euler;
	}

	/// Sets euler angle as member parameters, equivalent of this quaternion
	public void ToEulerAngle(ref T roll, ref T pitch, ref T yaw) pure const nothrow {
		Vector3T!T euler = ToEulerAngle();
		roll = euler.x;
		pitch = euler.y;
		yaw = euler.z;
	}
	unittest {
		auto q = QuaternionT!T(Vector3T!T(0.3f), 0.5f);
		T r, p, y;
		assert(__traits(compiles, q.ToEulerAngle));
		assert(__traits(compiles, q.ToEulerAngle(r, p, y)));
	}

	/// Returns a normalized quaternion
	public QuaternionT!T Normalize ( ) pure const nothrow {
		return QuaternionT!T(data.Normalize);
	}
	unittest {
		assert(__traits(compiles, QuaternionT!T.ToQuaternion(Vector3T!T(0.3)).Normalize));
	}

	/// Returns a conjugated quaternion
	public QuaternionT!T Conjugate ( ) pure const nothrow {
		return QuaternionT!T(float4(-data.x, -data.y, -data.z, data.w));
	}
	unittest {
		assert(__traits(compiles, QuaternionT!T(Vector3T!T(0.2f), 0.4f).Normalize.Conjugate));
	}

	// Returns a scaled quaternion
	public QuaternionT!T Scale(T scale) pure const nothrow {
		return QuaternionT!T(data*scale);
	}
	unittest {
		assert(__traits(compiles, QuaternionT!T(Vector3T!T(0.2f), 0.4f).Scale(0.5)));
	}

	/// quaternion * quaternion
	public QuaternionT!T opBinary(string op, U)(U rhs) pure const nothrow
	                      if (is(U : QuaternionT!T) && op == "*") {
		QuaternionT!T v;
		QuaternionT!T lhs = this;
		v.x =  lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y + lhs.w * rhs.x;
		v.y = -lhs.x * rhs.z + lhs.y * rhs.w + lhs.z * rhs.x + lhs.w * rhs.y;
		v.z =  lhs.x * rhs.y - lhs.y * rhs.x + lhs.z * rhs.w + lhs.w * rhs.z;
		v.w = -lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z + lhs.w * rhs.w;
		return v;
	}
	/// quaternion *= quaternion
	public void opOpAssign(string op, U)(U rhs) pure nothrow
	                       if (is(U : QuaternionT!T) && op == "*") {
		this = this * rhs;
	}

	/// quaternion + quaternion
	public QuaternionT!T opBinary(string op, U)(U rhs) pure const nothrow
	                       if(is(U : QuaternionT!T) && op == "+") {
		return QuaternionT!T(this.data + rhs.data);
	}
	/// quaternion += quaternion
	public void opOpAssign(string op, U)(U rhs) pure nothrow
	                       if (is(U : QuaternionT!T) && op == "+") {
		this = this + rhs;
	}

	unittest {
		QuaternionT!T q = QuaternionT!T(float4(0.4f));
		assert(__traits(compiles, q*q+q));
		q *= q;
		q += q;
	}
}
