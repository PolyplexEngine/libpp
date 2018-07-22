module polyplex.math.rectangle;
import polyplex.math;

/// Base template for all AABB-types.
/// Params:
/// type = all values get stored as this type
class Rectangle {
	private int x = 0;
	private int y = 0;
	private int width = 0;
	private int height = 0;

	this() { }

	this(int width, int height) {
		this.x = 0;
		this.y = 0;
		this.width = width;
		this.height = height;
	}

	this(int x, int y, int width, int height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public @property int X() { return this.x; }
	public @property void X(int x) { this.x = x; }

	public @property int Y() { return this.y; }
	public @property void Y(int y) { this.y = y; }

	public @property int Width() { return this.width; }
	public @property void Width(int width) { this.width = width; }

	public @property int Height() { return this.height; }
	public @property void Height(int height) { this.height = height; }

	public int Left() { return this.x; }
	public int Right() { return this.x + this.width; }
	public int Top() { return this.y; }
	public int Bottom() { return this.y + this.height; }
	public Vector2 Center() { return Vector2(this.x + (this.width/2), this.y + (this.height/2)); }

	public bool Intersects(Rectangle other) {
		if (other is null) return false;
		bool v = (other.Left > this.Right || other.Right < this.Left || other.Top > this.Bottom || other.Bottom < this.Top);
		return !v;
	}

	public bool Intersects(Vector2 other) {
		bool v = (other.X > this.Right || other.X < this.Left || other.Y > this.Bottom || other.Y < this.Top);
		return !v;
	}

	public Rectangle Displace(int x, int y) {
		return new Rectangle(this.X+x, this.Y+y, this.width, this.height);
	}

	public Rectangle Expand(int x, int y) {
		return new Rectangle(this.X-x, this.Y-y, this.width+x, this.height+y);
	}
}
