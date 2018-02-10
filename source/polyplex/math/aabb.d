module polyplex.math.aabb;

private {
    import polyplex.math.linalg : Vector, vec3;
    import polyplex.math : almost_equal;
}


/// Base template for all AABB-types.
/// Params:
/// type = all values get stored as this type
struct AABBT(type) {
    alias type at; /// Holds the internal type of the AABB.
    alias Vector!(at, 3) vec3; /// Convenience alias to the corresponding vector type.

    vec3 min = vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0); /// The minimum of the AABB (e.g. vec3(0, 0, 0)).
    vec3 max = vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0); /// The maximum of the AABB (e.g. vec3(1, 1, 1)).

    @safe pure nothrow:

    /// Constructs the AABB.
    /// Params:
    /// min = minimum of the AABB
    /// max = maximum of the AABB
    this(vec3 min, vec3 max) {
        this.min = min;
        this.max = max;
    }

    /// Constructs the AABB around N points (all points will be part of the AABB).
    static AABBT FromPoints(vec3[] points) {
        AABBT res;

        if(points.length == 0) {
            return res;
        }

        res.min = points[0];
        res.max = points[0];
        foreach(v; points[1..$]) {
            res.Expand(v);
        }
        
        return res;
    }

    unittest {
        AABBT!at a = AABBT!at(vec3(cast(at)0.0, cast(at)1.0, cast(at)2.0), vec3(cast(at)1.0, cast(at)2.0, cast(at)3.0));
        assert(a.min == vec3(cast(at)0.0, cast(at)1.0, cast(at)2.0));
        assert(a.max == vec3(cast(at)1.0, cast(at)2.0, cast(at)3.0));

        a = AABBT!at.FromPoints([vec3(cast(at)1.0, cast(at)0.0, cast(at)1.0), vec3(cast(at)0.0, cast(at)2.0, cast(at)3.0), vec3(cast(at)1.0, cast(at)0.0, cast(at)4.0)]);
        assert(a.min == vec3(cast(at)0.0, cast(at)0.0, cast(at)1.0));
        assert(a.max == vec3(cast(at)1.0,  cast(at)2.0, cast(at)4.0));
        
        a = AABBT!at.FromPoints([vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0), vec3(cast(at)2.0, cast(at)2.0, cast(at)2.0)]);
        assert(a.min == vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0));
        assert(a.max == vec3(cast(at)2.0, cast(at)2.0, cast(at)2.0));
    }

    /// Expands the AABB by another AABB. 
    void Expand(AABBT b) {
        if (min.X > b.min.X) min.X = b.min.X;
        if (min.Y > b.min.Y) min.Y = b.min.Y;
        if (min.Z > b.min.Z) min.Z = b.min.Z;
        if (max.X < b.max.X) max.X = b.max.X;
        if (max.Y < b.max.Y) max.Y = b.max.Y;
        if (max.Z < b.max.Z) max.Z = b.max.Z;
    }

    /// Expands the AABB, so that $(I v) is part of the AABB.
    void Expand(vec3 v) {
        if (v.X > max.X) max.X = v.X;
        if (v.Y > max.Y) max.Y = v.Y;
        if (v.Z > max.Z) max.Z = v.Z;
        if (v.X < min.X) min.X = v.X;
        if (v.Y < min.Y) min.Y = v.Y;
        if (v.Z < min.Z) min.Z = v.Z;
    }

    unittest {
        alias AABBT!at AABB;
        AABB a = AABB(vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0), vec3(cast(at)2.0, cast(at)4.0, cast(at)2.0));
        AABB b = AABB(vec3(cast(at)2.0, cast(at)1.0, cast(at)2.0), vec3(cast(at)3.0, cast(at)3.0, cast(at)3.0));

        AABB c;
        c.Expand(a);
        c.Expand(b);
        assert(c.min == vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0));
        assert(c.max == vec3(cast(at)3.0, cast(at)4.0, cast(at)3.0));

        c.Expand(vec3(cast(at)12.0, cast(at)2.0, cast(at)0.0));
        assert(c.min == vec3(cast(at)0.0,  cast(at)0.0, cast(at)0.0));
        assert(c.max == vec3(cast(at)12.0, cast(at)4.0,  cast(at)3.0));
    }

    /// Returns true if the AABBs intersect.
    /// This also returns true if one AABB lies inside another.
    bool Intersects(AABBT box) const {
        return (min.X < box.max.X && max.X > box.min.X) &&
               (min.Y < box.max.Y && max.Y > box.min.Y) &&
               (min.Z < box.max.Z && max.Z > box.min.Z);
    }

    unittest {
        alias AABBT!at AABB;
        assert(AABB(vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0), vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0)).Intersects(
               AABB(vec3(cast(at)0.5, cast(at)0.5, cast(at)0.5), vec3(cast(at)3.0, cast(at)3.0, cast(at)3.0))));

        assert(AABB(vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0), vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0)).Intersects(
               AABB(vec3(cast(at)0.5, cast(at)0.5, cast(at)0.5), vec3(cast(at)1.7, cast(at)1.7, cast(at)1.7))));

        assert(!AABB(vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0), vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0)).Intersects(
                AABB(vec3(cast(at)2.5, cast(at)2.5, cast(at)2.5), vec3(cast(at)3.0, cast(at)3.0, cast(at)3.0))));
    }

    /// Returns the Extent of the AABB (also sometimes called size).
    @property vec3 Extent() const {
        return max - min;
    }

    /// Returns the half Extent.
    @property vec3 HalfExtent() const {
        return (max - min) / 2;
    }

    unittest {
        alias AABBT!at AABB;
        AABBT!at a = AABBT!at(vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0), vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(a.Extent == vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(a.HalfExtent == a.Extent / 2);

        AABBT!at b = AABBT!at(vec3(cast(at)2.0, cast(at)2.0, cast(at)2.0), vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(b.Extent == vec3(cast(at)8.0, cast(at)8.0, cast(at)8.0));
        assert(b.HalfExtent == b.Extent / 2);
        
    }

    /// Returns the Area of the AABB.
    @property real Area() const {
        vec3 e = Extent;
        return 2.0 * (e.X * e.Y + e.X * e.Z + e.Y * e.Z);
    }

    unittest {
        alias AABBT!at AABB;
        AABB a = AABB(vec3(cast(at)0.0, cast(at)0.0, cast(at)0.0), vec3(cast(at)1.0, cast(at)1.0, cast(at)1.0));
        assert(a.Area == 6);

        AABB b = AABB(vec3(cast(at)2.0, cast(at)2.0, cast(at)2.0), vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(almost_equal(b.Area, 384));

        AABB c = AABB(vec3(cast(at)2.0, cast(at)4.0, cast(at)6.0), vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(almost_equal(c.Area, 208.0));
    }

    /// Returns the Center of the AABB.
    @property vec3 Center() const {
        return (max + min) / 2;
    }

    unittest {
        alias AABBT!at AABB;
        AABB a = AABB(vec3(cast(at)4.0, cast(at)4.0, cast(at)4.0), vec3(cast(at)10.0, cast(at)10.0, cast(at)10.0));
        assert(a.Center == vec3(cast(at)7.0, cast(at)7.0, cast(at)7.0));
    }

    /// Returns all vertices of the AABB, basically one vec3 per corner.
    @property vec3[] vertices() const {
        return [
            vec3(min.X, min.Y, min.Z),
            vec3(min.X, min.Y, max.Z),
            vec3(min.X, max.Y, min.Z),
            vec3(min.X, max.Y, max.Z),
            vec3(max.X, min.Y, min.Z),
            vec3(max.X, min.Y, max.Z),
            vec3(max.X, max.Y, min.Z),
            vec3(max.X, max.Y, max.Z),
        ];
    }

    bool opEquals(AABBT other) const {
        return other.min == min && other.max == max;
    }

    unittest {
        alias AABBT!at AABB;
        assert(AABB(vec3(cast(at)1.0, cast(at)12.0, cast(at)14.0), vec3(cast(at)33.0, cast(at)222.0, cast(at)342.0)) ==
               AABB(vec3(cast(at)1.0, cast(at)12.0, cast(at)14.0), vec3(cast(at)33.0, cast(at)222.0, cast(at)342.0)));
    }
}

alias AABBT!(float) AABB;


unittest {
    import std.typetuple;
    alias TypeTuple!(ubyte, byte, short, ushort, int, uint, float, double) Types;
    foreach(type ; Types)
    {
        alias AABBT!type aabbTestType;
        auto instance = aabbTestType();
    }
}
