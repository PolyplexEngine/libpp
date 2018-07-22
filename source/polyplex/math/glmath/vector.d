module polyplex.math.glmath.vector;
import std.math, std.traits, std.string;

private bool ProperVectorBinaryOperation(string op) {
	return op == "/" || op == "*" || op == "+" || op == "-" || op == "+=" || op == "-=";
}

private bool ProperVectorUnaryOperation(string op) {
	return op == "-" || op == "+";
}

private auto RSwizzleIndex(char c) {
	switch ( toLower(c) ) {
		default: assert(false, "Trying to swizzle invalid component '%s'".format(c));
		case 'r': case 'x': return 0;
		case 'g': case 'y': return 1;
		case 'b': case 'z': return 2;
		case 'a': case 'w': return 3;
	}
}
unittest {
	assert(RSwizzleIndex('r') == 0);
	assert(RSwizzleIndex('G') == 1);
	assert(RSwizzleIndex('z') == 2);
	assert(RSwizzleIndex('W') == 3);
}

// Returns a list of indices for the swizzle, intended to be enumerated over
private auto GenerateSwizzleList(string swizzle_list)() {
	assert(swizzle_list.length <= 4, "Can't swizzle with more than 4 elements");
	int[] buffer;
	static foreach ( swizzle; swizzle_list ) {
		buffer ~= RSwizzleIndex(swizzle);
	}
	return buffer;
}

/**
  Applies generic vector operations such as addition, subtraction etc.
**/
private template GenericVectorOperatorFunctionsMixin(T, int Dim) {
	private alias GVec = typeof(this);

	/// return a vector by this vector `op` a scalar T
	public GVec opBinary(string op)(T rhs) pure const nothrow if ( ProperVectorBinaryOperation(op) ) {
		GVec temp_vector;
		// Apply operator to each element in the vector. temp[i] = vec[i] op rhs
		static foreach ( i; 0 .. Dim )
			mixin(q{ temp_vector.data[i] = this.data[i] %s rhs; }.format(op));
		return temp_vector;
	}

	/// return a vector by a scalar T `op` this vector
	public GVec opBinaryRight(string op)(T lhs) pure const nothrow if ( ProperVectorBinaryOperation(op) ) {
		GVec temp_vector;
		// Apply operator to each element in the vector. temp[i] = lhs op vec[i]
		static foreach ( i; 0 .. Dim )
			mixin(q{ temp_vector.data[i] = lhs %s this.data[i] ; }.format(op));
		return temp_vector;
	}

	/// return a vector operated on by this `op` another vector (of same type)
	public GVec opBinary(string op)(GVec rhs) pure const nothrow if ( ProperVectorBinaryOperation(op) ) {
		GVec temp_vector;
		// Apply operator to each element in the vector. temp[i] = vec[i] op rhs[i]
		static foreach ( i; 0 .. Dim )
			mixin(q{ temp_vector.data[i] = this.data[i] %s rhs.data[i]; }.format(op));
		return temp_vector;
	}

	/// Operate on vector with a unary operator
	public GVec opUnary(string op)() pure const nothrow if ( ProperVectorUnaryOperation(op) ) {
		GVec temp_vector;
		// Apply unary operator to vector. temp[i] = op vec[i]
		static foreach ( i; 0 .. Dim )
			mixin(q{ temp_vector.data[i] = %s this.data[i]; }.format(op));
		return temp_vector;
	}

	/// Equality comparison (only on ints)
	static if ( is(Type == int) )
	public bool opEquals(GVec rhs) pure const nothrow {
		bool equality = true;
		// propagate equality checks throughout each element comparison of the vectors
		static foreach ( i; 0 .. Dim )
			equality &= this.data[i] == rhs.data[i];
		return equality;
	}

	/// Casts this vector to another vector type U
	public U opCast(U)() pure const nothrow if ( IsVector!U && U.Dim == Dim ) {
		U temp_vector;
		// Apply cast to each element of vector
		static foreach ( i; 0 .. Dim )
			temp_vector.data[i] = cast(U.Type)(this.data[i]);
		return temp_vector;
	}

	/// Operator assignment on a scalar or vector
	public void opOpAssign(string op, U)(U rhs) pure nothrow if ( __traits(isArithmetic, U) || IsVector!U ) {
		mixin(q{ this = this %s rhs; }.format(op));
	}
}

// Unittest on operations
unittest {
	assert(int3(5) == int3(5));
	assert(int3(3) != int3(5));
	assert((int3(6)/int3(2) - int3(1)) + int3(3)*int3(5) == int3(17));
	assert(int3(6) - 1 == int3(5));
	assert(1 - int3(6) == int3(-5));
	assert(-int3(6) == +int3(-6));
	assert(!__traits(compiles, int3(5)%int3(3)));
	assert(__traits(compiles, cast(float3)int3(3)));
}

/**
   Applies default functions that should be given to vectors, such as Zero and distance
 **/
private template GenericVectorDefaultFunctionsMixin(T, int Dim) {
	private alias GVec = typeof(this);

	/// Returns a vector of zero elements
	public static GVec Zero ( ) pure nothrow { return GVec(cast(T)0); }

	/// Returns a vector of one elements
	public static GVec One  ( ) pure nothrow { return GVec(cast(T)1); }

	/// Returns a vector of NaN elements (floating points only)
	static if (__traits(isFloating, T))
	public static GVec NaN  ( ) pure nothrow {
		return GVec(T.nan);
	}

	/// Dot product operator
	public T Dot(GVec rhs) pure const nothrow {
		T temp = 0;
		// multiply each element together and add to temp
		static foreach ( i; 0 .. Dim )
			temp += this.data[i]*rhs.data[i];
		return temp;
	}

	/// Magnitude/length of a vector (distance from origin)
	public alias Magnitude = Length;
	public T Length() pure const nothrow {
		T accumulator = 0;
		// Accumulate the squared of each element in the vector
		static foreach ( i; 0 .. Dim )
			accumulator += this.data[i]*this.data[i];
		// Sqrt the float equivalent and then cast to proper type
		return cast(T)sqrt(cast(float)accumulator);
	}

	/// Distance between two vectors
	public T Distance(GVec rhs) pure const nothrow {
		return (this - rhs).Length;
	}

	/// Returns a normalized vector
	GVec Normalize() pure const nothrow {
		return this.opBinary!"/"(this.Length());
	}
}

// unittest on generic functions
unittest {
	assert(int3(1, 2, 3).Dot(cast(int3)float3(4, 5, 6)) == 32);
	assert(int3(1, 2, 3).Length == 3);
	assert(int3(1, 2, 3).Distance(int3(4, 1, 3)) == 3);
	assert(int3.One.x == 1);
	assert(!__traits(compiles, int3.Nan));
	import std.math : abs;
	assert(abs(float3(0.2f, 0.6f, 0.5f).Normalize.x-0.248069f) <= 0.02f);
}

/**
  Applies assertions, immutables, introspections, component swizzling and other
    generic functions that can be applied to a vector
**/
private template GenericVectorMixin(T, int _Dim) {
	// -- assertions about type and length
	static assert(_Dim >= 2 && _Dim <= 4, "The length of a vector must be 2, 3 or 4.");
	static assert(__traits(isArithmetic, T), "Type must be arithmetic (float, int, etc)");
	// -- setup immutables
	public immutable static size_t Dim = _Dim;
	public static alias Type = T;

	// -- introspection functions
	/// Checks if vector U is compatible with this vector type
	public enum IsCompatible(U) = (U.Dim == Dim && is(U.Type == T));

	// -- mixins
	mixin GenericVectorOperatorFunctionsMixin!(Type, Dim);
	mixin GenericVectorDefaultFunctionsMixin!(Type, Dim);

	/// Swizzles on one single component returning a single value (ei .x, returning a T)
	private auto SwizzleOnOneComponent(string swizzle_list)() pure const nothrow {
		// Since GenerateSwizzleList returns an array, index the first element
		return this.data[(GenerateSwizzleList!swizzle_list)[0]];
	}

	/// Swizzles on multiple components returning a vector (ei .xy, returning Vector2T!T)
	private auto SwizzleOnMultipleComponents(string swizzle_list)() pure const nothrow {
		// create a temporary vector
		Vector!(T, swizzle_list.length) ret_vec;
		// iterate the swizzle list and fill vector
		static foreach ( iter, index; GenerateSwizzleList!swizzle_list )
			ret_vec.data[iter] = this.data[index];
		return ret_vec;
	}

	/// opDispatch for vector swizzling
	public @property auto opDispatch(string swizzle_list, U = void)() pure const nothrow if ( swizzle_list.length <= 4 ) {
		// Check if returning a single element, or a vector
		static if ( swizzle_list.length == 1 )
			return SwizzleOnOneComponent!swizzle_list;
		else
			return SwizzleOnMultipleComponents!swizzle_list;
	}

	/// opDispatch for vector swizzling assignment
	public @property auto opDispatch(string swizzle_list, U)(U x) pure nothrow {
		// Check if setting a single element or a list of elements
		static if ( swizzle_list.length == 1 ) {
			// GenerateSwizzleList returns an array, so get first element and set it to x
			this.data[(GenerateSwizzleList!swizzle_list)[0]] = x;
			return x; // return this scalar ( v.x = v.y = .. )
		} else {
			// iterate swizzle list and set values of this vector
			Vector!(T, swizzle_list.length) tvec = x; // convert scalar to vector
			static foreach ( iter, index; GenerateSwizzleList!swizzle_list )
				this.data[index] = tvec.data[iter];
			return tvec; // return this vector ( v.xy = v.zw = .. )
		}
	}

	/// Returns a pointer to the data container of this vector
	public inout(T)* ptr() pure inout nothrow { return data.ptr; }
}

// unittest on swizzling
unittest {
	int4 x = int4(1, 2, 3, 4);
	assert(x.xyzw == int4(1, 2, 3, 4));
	assert(x.xxxx == int4(1));
	assert(x.wzyx == int4(4, 3, 2, 1));
	assert(x.xz   == int2(1, 3));
	assert(x.x    == 1);
	int2 y = int2(1, 2);
	assert(y.xyxy == int4(1, 2, 1, 2));
	assert(y.yyy  == int3(2, 2, 2));
}

// --- Vector declaration and utility introspection functions
struct Vector(T, int Dim);

// `is` has an interesting property in that it can generate templates in-place
// using its second parameter. Thus you can use an argument-list to check if
// T is of any type Vector(U[0], U[1])
/// Returns if type is a vector
enum IsVector(T) = is(T : Vector!U, U...);

unittest {
	assert(!IsVector!float);
	assert(IsVector!float2);
}

// --- Vector2T struct
alias Vector2T(T) = Vector!(T, 2);
alias vec2 = Vector2T!float;
alias vec2i = Vector2T!int;
alias float2 = Vector2T!float;
alias int2 = Vector2T!int;

struct Vector(T, int _Dim:2) {
	public T[2] data = [0, 0];

	mixin GenericVectorMixin!(T, 2);

	/// Constructor for scalars
	public this(U)(U x) { data[] = cast(T)x; }

	/// Constructor for parameter lists
	public this(U)(U x, U y) { data[] = [x, y]; }

	/// Constructor for vectors of same type
	public this(Vector2T!T vec) { data[] = vec.data; }

	/// Constructor for explicit lists
	public this(T[] list) {
		assert(list.length == 2, "List length mismatch");
		data[] = list;
	}

	public string toString() { return `<%s, %s>`.format(data[0], data[1]); }
	public alias ToString = toString;
}

// --- Vector3T struct
alias Vector3T(T) = Vector!(T, 3);
alias vec3 = Vector3T!float;
alias vec3i = Vector3T!int;
alias float3 = Vector3T!float;
alias int3 = Vector3T!int;

struct Vector(T, int _Dim:3) {
	public T[3] data = [0, 0, 0];

	mixin GenericVectorMixin!(T, 3);

	/// Constructor for scalars
	public this(U)(U x) { data[] = cast(T)x; }

	/// Constructor for parameter lists
	public this(U)(U x, U y, U z) { data[] = [x, y, z]; }

	/// Constructor for vectors of same type
	public this(Vector3T!T vec) { data[] = vec.data; }

	/// Constructor for explicit lists
	public this(T[] list) {
		assert(list.length == 3, "List length mismatch");
		data[] = list;
	}

	public string toString() { return `<%s, %s, %s>`.format(data[0], data[1], data[2]); }
	public alias ToString = toString;

	public Vector3T!T Cross(Vector3T!T a, Vector3T!T b) pure const nothrow {
		return Vector3T!T(
			a.y*b.z - a.z*b.y,
			a.z*b.x - a.x * b.z,
			a.x*b.y - a.y * b.x);
	}
}

// --- Vector4T struct
alias Vector4T(T) = Vector!(T, 4);
alias vec4 = Vector4T!float;
alias vec4i = Vector4T!int;
alias float4 = Vector4T!float;
alias int4 = Vector4T!int;

struct Vector(T, int _Dim:4) {
	public T[4] data = [0, 0, 0, 0];

	mixin GenericVectorMixin!(T, 4);

	/// Constructor for scalars
	public this(U)(U x) { data[] = cast(T)x; }

	/// Constructor for parameter lists
	public this(U)(U x, U y, U z, U w) { data[] = [x, y, z, w]; }

	/// Constructor for vectors of same type
	public this(Vector4T!T vec) { data[] = vec.data; }

	/// Constructor for explicit lists
	public this(T[] list) {
		assert(list.length == 4, "List length mismatch");
		data[] = list;
	}

	string toString() { return `<%s, %s, %s, %s>`.format(data[0], data[1], data[2], data[3]); }
	alias ToString = toString;
}
