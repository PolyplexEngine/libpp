module polyplex.math.rectangle;
import polyplex.math;
import std.traits;

/// Base template for all AABB-types.
/// Params:
/// type = all values get stored as this type
struct RectangleT(T) if (isNumeric!T) {
public:
	union {
		struct {
			/// X coordinate of the top-left corner of the rectangle
			T X = 0;

			/// Y coordinate of the top-left corner of the rectangle
			T Y = 0;

			/// The width of the rectangle
			T Width = 0;

			/// The height of the rectangle
			T Height = 0;
			
		}

		/// Rectangle represented as an array, useful for passing data to the graphics API
		T[4] data;
	}

	/// Constructor
	this(W, H)(W width, H height) if (isNumeric!W && isNumeric!H) {
		this.Width = cast(T)width;
		this.Height = cast(T)height;
	}

	/// Constructor
	this(X, Y, W, H)(X x, Y y, W width, H height) if (isNumeric!X && isNumeric!Y && isNumeric!W && isNumeric!H) {
		this.X = cast(T)x;
		this.Y = cast(T)y;
		this.Width = cast(T)width;
		this.Height = cast(T)height;
	}

	@trusted RectangleT!T opBinary(string op, T)(T other) if (isNumeric!(T)) {
		import std.format;
		mixin(q{
			return Rectangle(
				X %1$s cast(T)other, 
				Y %1$s cast(T)other, 
				Width %1$s cast(T)other, 
				Height %1$s cast(T)other);
		}.format(op));
	}

	@trusted RectangleT!T opBinary(string op, T)(T other) if (IsRectangleT!T) {
		import std.format;
		mixin(q{
			return Rectangle(
				X %1$s cast(T)other.X, 
				Y %1$s cast(T)other.Y, 
				Width %1$s cast(T)other.Width, 
				Height %1$s cast(T)other.Height);
		}.format(op));
	}

	/**
		Gets the X coordinate of the left side of the rectangle
	*/
	T Left() { return this.X; }

	/**
		Gets the X coordinate of the right side of the rectangle
	*/
	T Right() { return this.X + this.Width; }

	/**
		Gets the Y coordinate of the top of the rectangle
	*/
	T Top() { return this.Y; }

	/**
		Gets the Y coordinate of the bottom of the rectangle
	*/
	T Bottom() { return this.Y + this.Height; }

	/**
		Gets the center of the rectangle (as floats)
	*/
	Vector2 Center() { return Vector2(this.X + (this.Width/2), this.Y + (this.Height/2)); }

	/**
		Gets wether this rectangle intersects another
	*/
	bool Intersects(T)(T other) if (IsRectangleT!T) {
		bool v = (other.Left >= this.Right || other.Right <= this.Left || other.Top >= this.Bottom || other.Bottom <= this.Top);
		return !v;
	}

	/**
		Gets wether a 2D vector is intersecting this rectangle
	*/
	bool Intersects(U)(U other) if (IsVector2T!U) {
		bool v = (other.X >= this.Right || other.X <= this.Left || other.Y >= this.Bottom || other.Y <= this.Top);
		return !v;
	}

	/**
		Returns a displaced version of this rectangle
	*/
	RectangleT!T Displace(T x, T y) {
		return RectangleT!T(this.X+x, this.Y+y, this.Width, this.Height);
	}

	/**
		Returns an expanded version of this rectangle
	*/
	RectangleT!T Expand(T)(T x, T y) {
		return RectangleT!T(this.X-x, this.Y-y, this.Width+(x*2), this.Height+(y*2));
	}
}

// Checks wether a type is a rectangle type
enum IsRectangleT(T) = is(T : RectangleT!U, U...);

alias Rectangle = RectangleT!float;
alias Rectanglei = RectangleT!int;