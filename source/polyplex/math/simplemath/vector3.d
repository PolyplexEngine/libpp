module polyplex.math.simplemath.vector3;
import polyplex.utils.strutils;
import std.math, std.traits, std.string;

private enum Dims = "XYZ";

// Copied from the GLMath implementation, checks if T is a Vector2T
enum IsVector3T(T) = is(T : Vector3T!U, U...);


public struct Vector3T(T) if (isNumeric!(T)) {
	public static alias Type = T;
	private T[3] data;
	
	/**
		Creates a new Vector3 of type (T), in which initial values are X, Y and Z.
	*/
	public this(T x, T y, T z) {
		data[0] = x;
		data[1] = y;
		data[2] = z;
	}	

	/**
		Creates a new Vector3 of type (T), in which initial values are X, Y and 0.
	*/
	public this(T x, T y) {
		data[0] = x;
		data[1] = y;
		data[2] = 0;
	}

	/**
		Creates a new Vector3 of type (T), in which all initial values are X.
	*/
	public this(T x) {
		data[0] = x;
		data[1] = x;
		data[2] = x;
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
		Pointer to the underlying array data.
	*/
	public T* ptr() { return data.ptr; }

	public Vector3T!(T) opBinary(string op)(Vector3T!(T) other) { 
		mixin(q{
			return Vector3T!({0})(
				this.X {1} other.X, 
				this.Y {1} other.Y, 
				this.Z {1} other.Z);
			}.Format(this.Type.stringof, op)
		); 
	}
	
	public void opOpAssign(string op)(Vector3T!(T) other) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	public Vector3T!(T) Distance(Vector3T!(T) other) {
		return other-this;
	}

	public static Vector3T!(T) Zero() {
		return Vector3T!(T)(0, 0, 0);
	}
}

alias Vector3 = Vector3T!float;
alias Vector3i = Vector3T!int;
