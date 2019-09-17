module polyplex.math.linear.vectors;
import std.math, std.traits, std.string, std.range.primitives, std.format;
import polyplex.math;

private:

/// Shared constructors between vectors
enum SharedVectorCtor = q{

	/// Special constructor that fills the vector with specified value
	this(Y)(Y value) if (isNumeric!Y) {
		static foreach(i; 0..Dimensions) {
			values[i] = cast(T)value;
		}
	}

	/// Construct from vector
	this(Y)(Y other) if (IsVector!Y) {
		static foreach(i; 0..Dimensions) {
			// If we're outside the bounds of the other vector then skip the axies
			static if (i < other.Dimensions) mixin(q{ values[i] = other.values[i]; }); 
		}
	}

	/// Construct from static array of coordinates
	this(T[Dimensions] values) {
		this = values[0..Dimensions];
	}

	/// Construct from dynamic array of coordinates
	this(T[] values) {
		this = values[0..Dimensions];
	}
};

/// Vector operations are implemented via this.
mixin template SharedVectorOp(T, GVector, int Dimensions) {

	static assert(Dimensions > 1 && Dimensions < 5, "The dimensions of a vector can minimum be 2, maximum be 4");

	/**
		OpenGL helper function to get the pointer to the start of the vector data.
	*/
	T* ptr() { return values.ptr; }

	/// Allow casting this vector to an other type of vector
	Y opCast(Y)() if (IsVector!Y) {
		return Y(this);
	}

	/// Allow doing binary operations between 2 vectors
	GVector opBinary(string op, T2)(T2 other) if (IsVector!T2) {
		GVector vec;
		static foreach(i; 0..Dimensions) {
			// If we're outside the bounds of the other vector then skip the axies
			static if (i < other.Dimensions) mixin(q{ vec.values[i] = this.values[i] %s other.values[i]; }.format(op)); 
		}
		return vec;
	}

	/// Allow doing binary operations between a vector and a numeric type
	GVector opBinary(string op, T2)(T2 other) if (isNumeric!(T2)) {
		GVector vec;
		static foreach(i; 0..Dimensions) {
			mixin(q{ vec.values[i] = this.values[i] %s other; }.format(op)); 
		}
		return vec;
	}

	/// Binary operations between this and a vector or a numeric type.
	void opOpAssign(string op, T2)(T2 other) if (isNumeric!T2 || IsVector!T2) {
		mixin(q{this = this %s other;}.format(op));
	}

	/// Binary operations between this and a numeric type.
	void opAssign(T2)(T2 other) if (isNumeric!T2) {
		this = [other];
	}

	/// Binary operations between this and a vector.
	void opAssign(T2)(T2 other) if (!is(T2 : GVector) && IsVector!T2) {
		this = cast(GVector)other;
	}

	/// Binary operations between this and arrays.
	void opAssign(T2)(T2 rhs) if (IsNumericArray!T2) {
		static foreach(i; 0..Dimensions) {
			values[i] = cast(T)rhs[i];
		}
	}

	/**
		Get the difference between 2 vectors
		Any difference outside the bounds of the vector will be ignored.
	*/
	GVector Difference(T2)(T2 other) if (IsVector!T2) {
		return other-this;
	}

	/**
		Get the distance between 2 vectors
		Any difference outside the bounds of the vector will be ignored.
	*/
	T Distance(T2)(T2 other) if (IsVector!T2) {
		return (other-this).Length;
	}

	/**
		Get the length/magnitude of this vector
	*/
	T Length() {
		T len;
		static foreach(i; 0..Dimensions) {
			len += (values[i]*values[i]);
		}
		return cast(T)Mathf.Sqrt(cast(float)len);
	}

	/**
		Get the length/magnitude of this vector
	*/
	alias Magnitude = Length;

	/**
		Get the normalized vector
	*/
	GVector Normalize() {
		// Normalize by dividing the values from the current values array by the magnitude/length
		GVector vec;
		immutable(T) len = Length();
		static foreach(i; 0..Dimensions) {
			vec.values[i] = values[i]/len;
		}
		return vec;
	}

	/**
		Get the dot product of 2 vectors
		Any difference outside the bounds of the vector will be ignored.
	*/
	T Dot(T2)(T2 other) if (IsVector!T2) {
		T dot;
		static foreach(i; 0..Dimensions) {
			static if (i < other.Dimensions) dot += (val*other.values[i]);
		}
		return cast(T)dot;
	}

	/**
		Returns a one vector (vector of all ones)
	*/
	static GVector One() {
		return GVector(1);
	}

	/**
		Returns a zero vector (vector of all zeroes)
	*/
	static GVector Zero() {
		return GVector(0);
	}

	/**
		Cross product of 2D vector
	*/
	GVector Cross()(GVector other) if (Dimensions == 2) {
		return GVector(
			(this.Y*other.Z)-(this.Z*other.Y),
			(this.X*other.Y)-(this.Y*other.X));
	}

	/**
		Cross product of 2D vector
	*/
	GVector Cross()(GVector other) if (Dimensions == 3) {
		return GVector(
			(this.Y*other.Z)-(this.Z*other.Y),
			(this.Z*other.X)-(this.X*other.Z),
			(this.X*other.Y)-(this.Y*other.X));
	}

	static if (Dimensions >= 2) {

		/**
			Returns a vector pointing to the global up
		*/
		static GVector Up() {
			GVector v;
			v.Y = -1;
			return v;
		}

		/**
			Returns a vector pointing to the global down
		*/
		static GVector Down() {
			GVector v;
			v.Y = 1;
			return v;
		}

		/**
			Returns a vector pointing to the global left
		*/
		static GVector Left() {
			GVector v;
			v.X = -1;
			return v;
		}

		/**
			Returns a vector pointing to the global right
		*/
		static GVector Right() {
			GVector v;
			v.X = 1;
			return v;
		}
	}

	static if (Dimensions >= 3) {

		/// TODO: If the Z axis is flipped then flip the logic here!

		/**
			Returns a vector pointing to the global forward
			This is only usable on Vectors with a Z axis!
		*/
		static GVector Forward() {
			GVector v;
			v.Z = 1;
			return v;
		}

		/**
			Returns a vector pointing to the global backward
			This is only usable on Vectors with a Z axis!
		*/
		static GVector Backward() {
			GVector v;
			v.Z = -1;
			return v;
		}

	}

	string toString() {
		import std.conv : text;
		return values.text;
	}
}


public:
/**
	A 2D vector
*/
@trusted 
nothrow
struct Vector2T(T) if (isNumeric!T) {
private:
	alias GVector = typeof(this);

public:
	/// The count of dimensions the vector consists of
	enum Dimensions = 2;

	alias Type = T;

	union {
		struct {
			/// The X component
			T X = 0;

			/// The Y component
			T Y = 0;
		}

		/// An array of the values in this vector
		T[Dimensions] values;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
	}

	mixin(SharedVectorCtor);
	mixin SharedVectorOp!(T, GVector, Dimensions);
}

/**
	A 3D vector
*/
@trusted 
nothrow
struct Vector3T(T) if (isNumeric!T) {
private:
	alias GVector = typeof(this);

public:
	/// The count of dimensions the vector consists of
	enum Dimensions = 3;

	alias Type = T;

	union {
		struct {
			/// The X component
			T X = 0;

			/// The Y component
			T Y = 0;

			/// The Z component
			T Z = 0;
		}

		/// An array of the values in this vector
		T[Dimensions] values;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y, Y z) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
		this.Z = cast(T)z;
	}
	
	mixin(SharedVectorCtor);
	mixin SharedVectorOp!(T, GVector, Dimensions);
}

/**
	A 4D vector
*/
@trusted 
nothrow
struct Vector4T(T) if (isNumeric!T) {
private:
	alias GVector = typeof(this);

public:
	/// The count of dimensions the vector consists of
	enum Dimensions = 4;

	alias Type = T;

	union {
		struct {
			/// The X component
			T X = 0;

			/// The Y component
			T Y = 0;

			/// The Z component
			T Z = 0;

			/// The Z component
			T W = 0;
		}

		/// An array of the values in this vector
		T[Dimensions] values;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y, Y z) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
		this.Z = cast(T)z;
	}

	/// Construct from X and Y coordinates
	this(Y)(Y x, Y y, Y z, Y w) if (isNumeric!Y) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
		this.Z = cast(T)z;
		this.W = cast(T)w;
	}

	// Implement shared vector operations & constructors
	mixin(SharedVectorCtor);
	mixin SharedVectorOp!(T, GVector, Dimensions);
}

// Copied from the GLMath implementation, checks if T is a Vector2T
enum IsVector2T(T) = is(T : Vector2T!U, U...);

// Copied from the GLMath implementation, checks if T is a Vector3T
enum IsVector3T(T) = is(T : Vector3T!U, U...);

// Copied from the GLMath implementation, checks if T is a Vector4T
enum IsVector4T(T) = is(T : Vector4T!U, U...);

enum IsNumericArray(T) = isArray!T && isNumeric!(ElementType!T);

//Combination of all IsVector
enum IsVector(T) = (IsVector2T!T || IsVector3T!T || IsVector4T!T);

alias Vector2 = Vector2T!float;
alias Vector2i = Vector2T!int;
alias Vector3 = Vector3T!float;
alias Vector3i = Vector3T!int;
alias Vector4 = Vector4T!float;
alias Vector4i = Vector4T!int;
