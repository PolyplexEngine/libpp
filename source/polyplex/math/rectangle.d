module polyplex.math.rectangle;

private {
    import polyplex.math.linalg : Vector, vec2;
    import polyplex.math : almost_equal;
}


/// Base template for all AABB-types.
/// Params:
/// type = all values get stored as this type
struct RectangleT(type) {
    alias type at; /// Holds the internal type of the AABB.
    alias Vector!(at, 2) vec2; /// Convenience alias to the corresponding vector type.

	at x, y, w, h;
	public @property at X() { return x; }
	public @property at Y() { return y; }
	public @property at Width() { return w; }
	public @property at Height() { return h; }
	public @property void X(at x) { this.x = x; }
	public @property void Y(at y) { this.y = y; }
	public @property void Width(at w) { this.w = w; }
	public @property void Height(at h) { this.h = h; }

    @safe pure nothrow:

    /// Constructs the AABB.
    /// Params:
    /// min = minimum of the AABB
    /// max = maximum of the AABB
    this(at x, at y, at w, at h) {
        this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
    }

    /// Expands the Rectangle by another Rectangle. 
    void Expand(RectangleT b) {
        if (x > b.X) x = b.X;
        if (y > b.Y) y = b.Y;
        if (w < b.Width) w = b.Width;
        if (h < b.Y) Height = b.Height;
    }

    /// Expands the Rectangle, so that $(I v) is part of the Rectangle.
    void Expand(vec2 v) {
        if (v.X > x) x = v.X;
        if (v.Y > y) y = v.Y;
        if (v.X < x) x = v.X;
        if (v.Y < y) y = v.Y;
    }

    /// Returns true if the Rectangles intersect.
    /// This also returns true if one AABB lies inside another.
    bool Intersects(RectangleT box) const {
        return (x < box.Width && x > box.X) &&
               (y < box.Height && y > box.Y);
    }

    /// Returns the Extent of the Rectangle (also sometimes called size).
    @property vec2 Extent() const {
        return vec2(x-w, y-h);
    }

    /// Returns the half Extent.
    @property vec2 HalfExtent() const {
        return (vec2(x, y) - vec2(w, h)) / 2;
    }

    /// Returns the Area of the Rectangle.
    @property real Area() const {
        vec2 e = Extent;
        return 2.0 * (e.X * e.Y);
    }

    /// Returns the Center of the Rectangle.
    @property vec2 Center() const {
        return (vec2(x+w, y+h)) / 2;
    }

    /// Returns all vertices of the Rectangle, basically one vec2 per corner.
    /*@property vec2[] vertices() const {
        return [
            vec2(min.X, min.Y, min.Z),
            vec2(min.X, min.Y, max.Z),
            vec2(min.X, max.Y, min.Z),
            vec2(min.X, max.Y, max.Z)
        ];
    }*/

    bool opEquals(RectangleT other) const {
        return vec2(other.X, other.Y) == vec2(x, y) && vec2(other.Width, other.Height) == vec2(w, h);
    }
}

alias RectangleT!(float) rect;


unittest {
    import std.typetuple;
    alias TypeTuple!(ubyte, byte, short, ushort, int, uint, float, double) Types;
    foreach(type ; Types)
    {
        alias Rectangle!type rectTestType;
        auto instance = rectTestType();
    }
}
