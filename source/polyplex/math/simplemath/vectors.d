module polyplex.math.simplemath.vectors;
import polyplex.utils.strutils;
import std.math, std.traits, std.string;
import polyplex.math.simplemath;
static import Mathf = polyplex.math.mathf;

/**
	A 2 dimensional vector.
*/
public struct Vector2T(T) if (isNumeric!(T)) {
	private alias GVector = typeof(this);
	public alias Type = T;
	enum Dimensions = 2;

	/**
		Due to https://issues.dlang.org/show_bug.cgi?id=8006 this has to be flipped like this

		TOOD: Replace with getter/setter structure once https://github.com/dlang/dmd/pull/7079 is merged.
	**/
	private @safe nothrow @property T* data() {
		return this.ptr;
	}
	
	private @property void data(T[Dimensions] data) {
		X = data[0];
		Y = data[1];
	}

	/// The X component
	public T X = 0;

	/// The Y component
	public T Y = 0;

	/// Constructor
	this(T x) {
		this.X = x;
		this.Y = x;
	}

	/// Constructor
	this(T x, T y) {
		this.X = x;
		this.Y = y;
	}

	this(Vector3T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
	}

	this(Vector4T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
	}

	/**
		Pointer to the underlying array data.
	*/
	public T* ptr() { return &X; }

	// Binary actions.
	public @trusted nothrow GVector opBinary(string op, T2)(T2 other) if (IsVector!T2) { 
		// Operation on these, (due to being smallest size) can be done faster this way.
		mixin(q{
			return GVector(
				this.X {0} other.X, 
				this.Y {0} other.Y);
			}.Format(op)
		); 
	}

	// Binary actions numeric.
	public @trusted nothrow GVector opBinary(string op, T2)(T2 other) if (isNumeric!(T2)) {
		mixin(q{
			return GVector(
				this.X {0} other, 
				this.Y {0} other);
			}.Format(op)
		); 
	}

	// Binary Action w/ assignment
	public @trusted nothrow void opOpAssign(string op, T2)(T2 other) if (isNumeric!(T2) || IsVector!(T2)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public @trusted nothrow GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public @trusted nothrow T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public @trusted nothrow T Length() {
		T len = (X*X)+(Y*Y);
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public @trusted nothrow GVector Normalize() {
		GVector o;
		T len = Length();
		o.X = this.X/len;
		o.Y = this.Y/len;
		return o;
	}

	/// Dot product of a vector.
	public @trusted nothrow T Dot(GVector other) {
		return (this.X*other.X)+(this.Y*other.Y);
	}

	/**
		Returns:
			Initial (zero) state of this vector.
	**/
	public static GVector Zero() {
		return GVector(0, 0);
	}

	/**
		Returns:
			Initial (one) state of this vector.
	**/
	public static GVector One() {
		return GVector(1, 1);
	}
	
	/**
		Returns:
			Up unit vector
	**/
	public static GVector Up() {
		return GVector(0, 1);
	}

	/**
		Returns:
			Down unit vector
	**/
	public static GVector Down() {
		return GVector(0, -1);
	}

	/**
		Returns:
			Left unit vector
	**/
	public static GVector Left() {
		return GVector(0, -1);
	}

	/**
		Returns:
			Right unit vector
	**/
	public static GVector Right() {
		return GVector(0, 1);
	}

	/**
		Returns:
			String representation of the array.
	**/
	public string ToString() {
		string o = "<";
		static foreach(i; 0 .. Dimensions) {
			switch(i) {
				case (Dimensions-1):
					o~= "{0}".Format(this.data[i]);
					break;
				default:
					o ~= "{0}, ".Format(this.data[i]);
					break;
			}
		}
		return o~">";
	}

	/// Backwards compatiblity with glmath.
	alias toString = ToString;
}

public struct Vector3T(T) if (isNumeric!T) {
	private alias GVector = typeof(this);
	public alias Type = T;
	enum Dimensions = 3;

	/**
		Due to https://issues.dlang.org/show_bug.cgi?id=8006 this has to be flipped like this

		TOOD: Replace with getter/setter structure once https://github.com/dlang/dmd/pull/7079 is merged.
	**/
	private @safe nothrow @property T* data() {
		return this.ptr;
	}
	
	private @property void data(T[Dimensions] data) {
		X = data[0];
		Y = data[1];
		Z = data[2];
	}

	/// The X component
	public T X = 0;

	/// The Y component
	public T Y = 0;

	// The Z component
	public T Z = 0;

	/// Constructor
	this(T x) {
		this.X = x;
		this.Y = x;
		this.Z = 0;
	}

	/// Constructor
	this(T x, T y) {
		this.X = x;
		this.Y = y;
		this.Z = 0;
	}

	/// Constructor
	this(T x, T y, T z) {
		this.X = x;
		this.Y = y;
		this.Z = z;
	}


	this(Vector2T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
		this.Z = 0;
	}

	this(Vector4T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
		this.Z = vec.Z;
	}

	/**
		Pointer to the underlying array data.
	*/
	public T* ptr() { return &X; }

	/**
		Generic opBinary operation for Vectors.
	*/
	public @trusted nothrow GVector opBinary(string op, T2)(T2 other) if (IsVector!T2) {
		GVector o;
		// Get the length of the smallest vector
		
		static if (other.Dimensions < this.Dimensions) enum len = other.Dimensions;
		else enum len = this.Dimensions;

		// Do the operations.
		static foreach(i; 0 .. len) {
			mixin(q{o.data[i] = this.data[i] {0} other.data[i];}.Format(op));
		}
		return o;
	}

	// Binary actions numeric.
	public @trusted nothrow GVector opBinary(string op)(T other) if (isNumeric!(T)) {
		mixin(q{
			return GVector(
				this.X {0} other, 
				this.Y {0} other, 
				this.Z {0} other);
			}.Format(op)
		); 
	}

	// Binary Action w/ assignment
	public @trusted nothrow void opOpAssign(string op)(T other) if (isNumeric!(T) || IsVector!(T)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public @trusted nothrow GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public @trusted nothrow T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public @trusted nothrow T Length() {
		T len = (X*X)+(Y*Y)+(Z*Z);
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public @trusted nothrow GVector Normalize() {
		GVector o;
		T len = Length();
		static foreach(i; 0 .. Dimensions) {
			o.data[i] = this.data[i]/len;
		}
		return o;
	}

	/// Dot product of a vector.
	public @trusted nothrow T Dot(GVector other) {
		return (this.X*other.X)+(this.Y*other.Y)+(this.Z*other.Z);
	}

	/// Cross product of a vector.
	public @trusted nothrow GVector Cross(GVector other) {
		return GVector(
			(this.Y*other.Z)-(this.Z*other.Y),
			(this.Z*other.X)-(this.X*other.Z),
			(this.X*other.Y)-(this.Y*other.X));
	}

	/**
		Returns:
			Initial (zero) state of this vector.
	**/
	public static Vector3T!(T) Zero() {
		return Vector3T!(T)(0, 0, 0);
	}

	/**
		Returns:
			Initial (one) state of this vector.
	**/
	public static GVector One() {
		return GVector(1, 1, 1);
	}

	/**
		Returns:
			Up unit vector
	**/
	public static GVector Up() {
		return GVector(0, -1, 0);
	}

	/**
		Returns:
			Down unit vector
	**/
	public static GVector Down() {
		return GVector(0, 1, 0);
	}

	/**
		Returns:
			Left unit vector
	**/
	public static GVector Left() {
		return GVector(0, -1, 0);
	}

	/**
		Returns:
			Right unit vector
	**/
	public static GVector Right() {
		return GVector(0, 1, 0);
	}

	/**
		Returns:
			Left unit vector
	**/
	public static GVector Forward() {
		return GVector(0, 0, -1);
	}

	/**
		Returns:
			Right unit vector
	**/
	public static GVector Back() {
		return GVector(0, 0, 1);
	}

	/**
		Returns:
			String representation of the array.
	**/
	public string ToString() {
		string o = "<";
		static foreach(i; 0 .. Dimensions) {
			switch(i) {
				case (Dimensions-1):
					o~= "{0}".Format(this.data[i]);
					break;
				default:
					o ~= "{0}, ".Format(this.data[i]);
					break;
			}
		}
		return o~">";
	}
	
	/// Backwards compatiblity with glmath.
	alias toString = ToString;
}

public struct Vector4T(T) if (isNumeric!(T)) {
	private alias GVector = typeof(this);
	public alias Type = T;
	enum Dimensions = 4;

	/**
		Due to https://issues.dlang.org/show_bug.cgi?id=8006 this has to be flipped like this

		TOOD: Replace with getter/setter structure once https://github.com/dlang/dmd/pull/7079 is merged.
	**/
	private @safe nothrow @property T* data() {
		return this.ptr;
	}

	private @property void data(T[Dimensions] data) {
		X = data[0];
		Y = data[1];
		Z = data[2];
		W = data[3];
	}

	/// The X component
	public T X = 0;

	/// The Y component
	public T Y = 0;

	// The Z component
	public T Z = 0;

	// The W component
	public T W = 0;

	/// Constructor
	this(T x) {
		this.X = x;
		this.Y = x;
		this.Z = 0;
		this.W = 0;
	}

	/// Constructor
	this(T x, T y) {
		this.X = x;
		this.Y = y;
		this.Z = 0;
		this.W = 0;
	}

	/// Constructor
	this(T x, T y, T z) {
		this.X = x;
		this.Y = y;
		this.Z = z;
		this.W = 0;
	}

	/// Constructor
	this(T x, T y, T z, T w) {
		this.X = x;
		this.Y = y;
		this.Z = z;
		this.W = w;
	}

	this(Vector2T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
		this.Z = 0;
		this.W = 0;
	}

	this(Vector3T!T vec) {
		this.X = vec.X;
		this.Y = vec.Y;
		this.Z = vec.Z;
		this.W = 0;
	}

	/**
		Pointer to the underlying array data.
	*/
	public T* ptr() { return &X; }
	
	/**
		Generic opBinary operation for Vectors.
	*/
	public @trusted nothrow GVector opBinary(string op, T2)(T2 other) if (IsVector!(T2)) {
		GVector o;
		// Get the length of the smallest vector
		
		static if (other.Dimensions < this.Dimensions) enum len = other.Dimensions;
		else enum len = this.Dimensions;

		// Do the operations.
		static foreach(i; 0 .. len) {
			mixin(q{o.data[i] = this.data[i] {0} other.data[i];}.Format(op));
		}
		return o;
	}
	
	// Binary actions numeric.
	public @trusted nothrow GVector opBinary(string op)(T other) if (isNumeric!(T)) {
		mixin(q{
			return GVector(
				this.X {1} other, 
				this.Y {1} other, 
				this.Z {1} other, 
				this.W {1} other);
			}.Format(T.stringof, op)
		); 
	}

	// Binary Action w/ assignment
	public @trusted nothrow void opOpAssign(string op, T2)(T2 other) if (isNumeric!(T2) || IsVector!(T2)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public @trusted nothrow GVector Difference(T2)(T2 other) if (IsVector!T2){
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public @trusted nothrow T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public @trusted nothrow T Length() {
		T len = (X*X)+(Y*Y)+(Z*Z)+(W*W);
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public @trusted nothrow GVector Normalize() {
		GVector o;
		T len = Length();
		static foreach(i; 0 .. Dimensions) {
			o.data[i] = this.data[i]/len;
		}
		return o;
	}

	/// Dot product of a vector.
	public @trusted nothrow T Dot(GVector other) {
		return (this.X*other.X)+(this.Y*other.Y)+(this.Z*other.Z)+(this.W*other.W);
	}

	/**
		Returns:
			Initial (zero) state of this vector.
	**/
	public static GVector Zero() {
		return GVector(0, 0, 0, 0);
	}

	/**
		Returns:
			Initial (one) state of this vector.
	**/
	public static GVector One() {
		return GVector(1, 1, 1, 1);
	}

	/**
		Returns:
			String representation of the array.
	**/
	public string ToString() {
		string o = "<";
		static foreach(i; 0 .. Dimensions) {
			switch(i) {
				case (Dimensions-1):
					o~= "{0}".Format(this.data[i]);
					break;
				default:
					o ~= "{0}, ".Format(this.data[i]);
					break;
			}
		}
		return o~">";
	}
	
	/// Backwards compatiblity with glmath.
	alias toString = ToString;
}

// Copied from the GLMath implementation, checks if T is a Vector2T
enum IsVector2T(T) = is(T : Vector2T!U, U...);

// Copied from the GLMath implementation, checks if T is a Vector3T
enum IsVector3T(T) = is(T : Vector3T!U, U...);

// Copied from the GLMath implementation, checks if T is a Vector4T
enum IsVector4T(T) = is(T : Vector4T!U, U...);

//Combination of all IsVector
enum IsVector(T) = (IsVector2T!T || IsVector3T!T || IsVector4T!T);

alias Vector2 = Vector2T!float;
alias Vector2i = Vector2T!int;
alias Vector3 = Vector3T!float;
alias Vector3i = Vector3T!int;
alias Vector4 = Vector4T!float;
alias Vector4i = Vector4T!int;
