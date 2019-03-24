module polyplex.math.glmath.geometry;
import polyplex.math.glmath.vector;

alias Ray2D = RayT!float2;
alias Ray = RayT!float3;
/// A ray that supports two and three dimensions
struct RayT(VT) if(is(VT==float2) || is(VT==float3)) {
  public VT ori;
  public VT dir;
  immutable alias VectorType = VT;

  /// Constructs a ray with an origin and direction
  public this ( VT origin, VT direction ) pure nothrow {
    ori = origin;
    dir = direction;
  }

  /// Returns a ray with a normalized ray direction
  RayT!VT Normalize ( ) pure nothrow {
    return RayT!VT(ori, dir.Normalize);
  }
}

unittest {
  import std.traits;
  assert(__traits(compiles, Ray(float3(0.5f), float3(0.2f, 0.7f, 0f).Normalize)));
  assert(__traits(compiles, Ray(float3(0.5f), float3(0.2f, 0.7f, 0f)).Normalize));
}
