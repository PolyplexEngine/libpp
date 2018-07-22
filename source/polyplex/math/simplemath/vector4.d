module polyplex.math.simplemath.vector4;
import polyplex.utils.strutils;
import std.math, std.traits, std.string;

private enum Dims = "XYZW";

// Copied from the GLMath implementation, checks if T is a Vector2T
enum IsVector4T(T) = is(T : Vector4T!U, U...);

public struct Vector4T(T) if (isNumeric!(T)) {
	public static alias Type = T;
	private T[4] data;
	
	/**
		Creates a new Vector4 of type (T), in which initial values are X, Y, Z and W.
	*/
	public this(T x, T y, T z, T w) {
		data[0] = x;
		data[1] = y;
		data[2] = z;
		data[3] = w;
	}	
	
	/**
		Creates a new Vector4 of type (T), in which initial values are X, Y, Z and 0.
	*/
	public this(T x, T y, T z) {
		data[0] = x;
		data[1] = y;
		data[2] = z;
		data[3] = 0;
	}	

	/**
		Creates a new Vector4 of type (T), in which initial values are X, Y, 0 and 0.
	*/
	public this(T x, T y) {
		data[0] = x;
		data[1] = y;
		data[2] = 0;
		data[3] = 0;
	}

	/**
		Creates a new Vector4 of type (T), in which all initial values are X.
	*/
	public this(T x) {
		data[0] = x;
		data[1] = x;
		data[2] = x;
		data[3] = x;
	}

	/**
		The X component.	
	*/
	public T X() { return data[0]; }
	public void X(T value) { data[0] = value; }
		
	/**
		The Y component.	
	*/
	public T Y() { return data[1]; }
	public void Y(T value) { data[1] = value; }

	/**
		The Z component.	
	*/
	public T Z() { return data[2]; }
	public void Z(T value) { data[2] = value; }

	/**
		The W component.	
	*/
	public T W() { return data[3]; }
	public void W(T value) { data[3] = value; }

	/**
		Pointer to the underlying array data.
	*/
	public T* ptr() { return data.ptr; }

	public Vector4T!(T) opBinary(string op)(Vector4T!(T) other) { 
		mixin(q{
			return Vector4T!({0})(
				this.X {1} other.X, 
				this.Y {1} other.Y, 
				this.Z {1} other.Z,
				this.W {1} other.W);
			}.Format(T.stringof, op)
		); 
	}
	
	public void opOpAssign(string op)(Vector3T!(T) other) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	public Vector4T!(T) Distance(Vector4T!(T) other) {
		return other-this;
	}

	public static Vector4T!(T) Zero() {
		return Vector4T!(T)(0, 0, 0, 0);
	}
}

alias Vector4 = Vector4T!float;
alias Vector4i = Vector4T!int;
