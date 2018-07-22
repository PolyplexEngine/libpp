module polyplex.math.simplemath.vector2;
import polyplex.utils.strutils;
import std.math, std.traits, std.string;

private enum Dims = "XY";

// Copied from the GLMath implementation, checks if T is a Vector2T
enum IsVector2T(T) = is(T : Vector2T!U, U...);

/**
	A 2 dimensional vector.
*/
public struct Vector2T(T) if (isNumeric!(T)) {
	public static alias Type = T;
	private T[2] data;
	
	/**
		Creates a new Vector2 of type (T), in which initial values are X and Y.
	*/
	public this(T x, T y) {
		data[0] = x;
		data[1] = y;
	}

	/**
		Creates a new Vector2 of type (T), in which all initial values are X.
	*/
	public this(T x) {
		data[0] = x;
		data[1] = x;
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
		Pointer to the underlying array data.
	*/
	public T* ptr() { return data.ptr; }

	// Binary actions.
	public Vector2T!(T) opBinary(string op)(Vector2T!(T) other) { 
		mixin(q{
			return Vector2T!({0})(
				this.X {1} other.X, 
				this.Y {1} other.Y);
			}.Format(T.stringof, op)
		); 
	}

	// Binary Action w/ assignment
	public void opOpAssign(string op)(Vector2T!(T) other) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	public Vector2T!(T) Distance(Vector2T!(T) other) {
		return other-this;
	}

	public static Vector2T!(T) Zero() {
		return Vector2T!(T)(0, 0);
	}
	
}

alias Vector2 = Vector2T!float;
alias Vector2i = Vector2T!int;
