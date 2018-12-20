module polyplex.math.rectangle;
import polyplex.math;

/// Base template for all AABB-types.
/// Params:
/// type = all values get stored as this type
class Rectangle {
public:
	int X = 0;
	int Y = 0;
	int Width = 0;
	int Height = 0;

	this() { }

	this(int width, int height) {
		this.X = 0;
		this.Y = 0;
		this.Width = width;
		this.Height = height;
	}

	this(int x, int y, int width, int height) {
		this.X = x;
		this.Y = y;
		this.Width = width;
		this.Height = height;
	}

	import std.traits;
	@trusted Rectangle opBinary(string op, T)(T other) if (isNumeric!(T)) {
		import std.format;
		mixin(q{
			return new Rectangle(X %s other, Y %s other, Width %s other, Height %s other);
		}.format(op, op, op, op));
	}

	@trusted Rectangle opBinary(string op, T)(T other) if (is(T : Rectangle)) {
		import std.format;
		mixin(q{
			return new Rectangle(X %s other.X, Y %s other.Y, Width %s other.Width, Height %s other.Height);
		}.format(op, op, op, op));
	}

	int Left() { return this.X; }
	int Right() { return this.X + this.Width; }
	int Top() { return this.Y; }
	int Bottom() { return this.Y + this.Height; }
	Vector2 Center() { return Vector2(this.X + (this.Width/2), this.Y + (this.Height/2)); }

	bool Intersects(Rectangle other) {
		if (other is null) return false;
		bool v = (other.Left > this.Right || other.Right < this.Left || other.Top > this.Bottom || other.Bottom < this.Top);
		return !v;
	}

	bool Intersects(Vector2 other) {
		bool v = (other.X > this.Right || other.X < this.Left || other.Y > this.Bottom || other.Y < this.Top);
		return !v;
	}

	Rectangle Displace(int x, int y) {
		return new Rectangle(this.X+x, this.Y+y, this.Width, this.Height);
	}

	Rectangle Expand(int x, int y) {
		return new Rectangle(this.X-x, this.Y-y, this.Width+x, this.Height+y);
	}
}
