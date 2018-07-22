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
	public GVector opBinary(string op, T2)(T2 other) if (IsVector!T2) { 
		// Operation on these, (due to being smallest size) can be done faster this way.
		mixin(q{
			return GVector(
				this.X {0} other.X, 
				this.Y {0} other.Y);
			}.Format(op)
		); 
	}

	// Binary actions numeric.
	public GVector opBinary(string op, T2)(T2 other) if (isNumeric!(T2)) {
		mixin(q{
			return GVector(
				this.X {0} other, 
				this.Y {0} other);
			}.Format(op)
		); 
	}

	// Binary Action w/ assignment
	public void opOpAssign(string op, T2)(T2 other) if (isNumeric!(T2) || IsVector!(T2)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public T Length() {
		T len;
		static foreach(i; 0 .. Dimensions) {
			len += this.data[i] * this.data[i];
		}
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public GVector Normalize() {
		GVector o;
		T len = Length();
		static foreach(i; 0 .. Dimensions) {
			o.data[i] = this.data[i]/len;
		}
		return o;
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

	/**
		Generic opBinary operation for Vectors.
	*/
	public GVector opBinary(string op, T2)(T2 other) if (IsVector!T2) {
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
	public GVector opBinary(string op)(T other) if (isNumeric!(T)) {
		mixin(q{
			return GVector(
				this.X {0} other, 
				this.Y {0} other, 
				this.Z {0} other);
			}.Format(op)
		); 
	}

	// Binary Action w/ assignment
	public void opOpAssign(string op)(T other) if (isNumeric!(T) || IsVector!(T)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public T Length() {
		T len;
		static foreach(i; 0 .. Dimensions) {
			len += this.data[i] * this.data[i];
		}
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public GVector Normalize() {
		GVector o;
		T len = Length();
		static foreach(i; 0 .. Dimensions) {
			o.data[i] = this.data[i]/len;
		}
		return o;
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
	
	/**
		Generic opBinary operation for Vectors.
	*/
	public GVector opBinary(string op, T2)(T2 other) if (IsVector!(T2)) {
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
	public GVector opBinary(string op)(T other) if (isNumeric!(T)) {
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
	public void opOpAssign(string op, T2)(T2 other) if (isNumeric!(T2) || IsVector!(T2)) { 
		mixin(q{this = this {0} other;}.Format(op));
	}

	/**
		Returns:
			The difference between the 2 vectors.
	**/
	public GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Returns:
			The distance between this and another vector.
	**/
	public T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Returns:
			The length/magnitude of this vector.
	**/
	public T Length() {
		T len;
		static foreach(i; 0 .. Dimensions) {
			len += this.data[i] * this.data[i];
		}
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Returns:
			A normalized version of this vector.
	**/
	public GVector Normalize() {
		GVector o;
		T len = Length();
		static foreach(i; 0 .. Dimensions) {
			o.data[i] = this.data[i]/len;
		}
		return o;
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
