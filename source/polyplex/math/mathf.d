module polyplex.math.mathf;
import std.traits; // for some introspection (ei isScalar)
static import std.math; // for creating public aliases
// public imports of math constants
public import std.math : E, PI, PI_2, PI_4, M_1_PI, M_2_PI, M_2_SQRTPI, LN10,
                         LN2, LOG2, LOG2E, LOG2T, LOG10E, SQRT2, SQRT1_2;
/// TAU = PI*2
public enum real TAU = 6.28318530717958647692;

// public aliases of std library math functions to capitalized aliases
public alias Abs = std.math.abs;
public alias Sin = std.math.sin;
public alias Cos = std.math.cos;
public alias Tan = std.math.tan;
public alias Sqrt = std.math.sqrt;
public alias ASin = std.math.asin;
public alias ACos = std.math.acos;
public alias ATan = std.math.atan;
public alias ATan2 = std.math.atan2;
public alias SinH = std.math.sinh;
public alias CosH = std.math.cosh;
public alias TanH = std.math.tanh;
public alias ASinH = std.math.asinh;
public alias ACosH = std.math.acosh;
public alias ATanH = std.math.atanh;
public alias Ceil = std.math.ceil;
public alias Floor = std.math.floor;
public alias Round = std.math.round;
public alias Truncate = std.math.trunc;
public alias Pow = std.math.pow;
public alias Exp = std.math.exp;
public alias Exp2 = std.math.exp2;
public alias LogNatural = std.math.log;
public alias LogBase2 = std.math.log2;
public alias LogBase10 = std.math.log10;
public alias Fmod = std.math.fmod;
public alias Remainder = std.math.remainder;
public alias IsFinite = std.math.isFinite;
public alias IsIdentical = std.math.isIdentical;
public alias IsInfinity = std.math.isInfinity;
public alias IsNaN = std.math.isNaN;
public alias IsPowerOf2 = std.math.isPowerOf2;
public alias Sign = std.math.sgn;


/// Checks if two floating-point scalars are approximately
/// equal to each other by some epsilon
bool ApproxEquals(T)(T a, T b, T eps) pure nothrow if (__traits(isFloating, T)) {
	return Abs(a-b) < eps;
}
unittest {
	assert(ApproxEquals(1f, 1.001f, 0.1f));
	assert(!ApproxEquals(-1f, 1.001f, 0.1f));
	assert(ApproxEquals(10f, 10f, 0.001f));
	assert(!ApproxEquals(10f, 10.01f, 0.001f));
}

/// Converts quantity of degrees to radians
T ToRadians(T)(T degrees) pure nothrow {
	return (cast(T)(PI)*degrees)/cast(T)180;
}
/// Converts quantity of radians to degrees
T ToDegrees(T)(T radians) pure nothrow {
	return (180 * radians)/cast(T)PI;
}
unittest {
	assert(ApproxEquals(ToRadians(90f), ToRadians(ToDegrees(PI_2)), 0.1f));
	assert(ApproxEquals(ToRadians(360f+45f)-TAU, PI_4, 0.01f));
}

/// Minimum of two scalar elements
T Min(T)(T scalar_a, T scalar_b) pure nothrow if (__traits(isScalar, T)) {
	return ( scalar_a < scalar_b ? scalar_a : scalar_b );
}
unittest {
	assert(Min(5, 10) == 5);
	assert(Min(3, -5) == -5);
	assert(Min(25.0f, 3) == 3);
	assert(!__traits(compiles, Min("a", "b")));
	assert(__traits(compiles, Min('a', 'b')));
}

/// Maximum of two scalar elements
T Max(T)(T scalar_a, T scalar_b) pure nothrow if (__traits(isScalar, T)) {
	return ( scalar_a > scalar_b ? scalar_a : scalar_b );
}
unittest {
	assert(Max(5, 10) == 10);
	assert(Max(3, -5) == 3);
	assert(Max(25.0f, 3) == 25.0f);
	assert(!__traits(compiles, Max("a", "b")));
	assert(__traits(compiles, Max('a', 'b')));
}

/// Clamps scalar elements
T Clamp(T)(T x, T min, T max) pure nothrow if (__traits(isScalar, T)) {
	if ( x < min ) return min;
	if ( x > max ) return max;
	return x;
}
unittest {
	assert(Clamp(3, 0, 10) == 3);
	assert(Clamp(3, 5, 10) == 5);
	assert(Clamp(3, -2, 2) == 2);
}

/// Steps scalar `a` on edge `edge`. Returns 0 if a < edge, otherwise 1
T Step(T)(T edge, T a) pure nothrow if (__traits(isScalar, T)) {
	return (a >= edge);
}

/// -- All interpolation methods based from
///    http://paulbourke.net/miscellaneous/interpolation/

/** Linear interpolation on scalar elements. Interpolates between two scalar
      values `x` and `y` using a linear gradient `a`
  Params:
    x = The minimum element to interpolate by. The result of this function
          equals `x` when `a = 0`.
    y = The maximum element to interpolate by. The result of this function
          equals `x` when `a = 1`.
    a = The gradient to interpolate between `x` and `y`. Should be a value
          between `0f` and `1f`, although this function will clamp it to that
          range. For example, the result of this function will equal (x+y)/2
          when `a = 0.5`
**/
T LinearInterpolation(T)(T x, T y, float a) pure nothrow if (__traits(isScalar, T)) {
	a = Clamp(a, 0f, 1f);
	return cast(T)(x*(1.0f - a) + y*a);
}
/// Alias for linear interpolation, to follow the same GLSL convention
alias Mix = LinearInterpolation;
unittest {
	assert(LinearInterpolation(0f, 1f, 0.5f) == 0.5f);
	assert(LinearInterpolation(0f, 2f, 0.5f) == 1.0f);
	assert(LinearInterpolation(0f, 2f, 0.0f) == 0.0f);
	assert(LinearInterpolation(0f, 2f, 1.0f) == 2.0f);
	assert(LinearInterpolation(0f, 2f, 3.0f) == 2.0f);
	assert(LinearInterpolation(0f, 2f, -1.0f) == 0.0f);
}

/** Cosine interpolation on scalar elements. It interpolates between
      two scalars `x` and `y` using a cosine-weighted `a` (this function
      applies the cosine-weight). Check `LinearInterpolation` for more
      details.
**/
T CosineInterpolation(T)(T x, T y, float a) pure nothrow if (__traits(isScalar, T)) {
	return LinearInterpolation(x, y, (1.0f - Cos(a*PI))/2.0f);
}
unittest {
	assert(__traits(compiles, CosineInterpolation(0, 1, 0.5f)));
	assert(__traits(compiles, CosineInterpolation(0f, 1f, 0.5f)));
}

/** Cube interpolation using Catmull-Rom splines on scalar elements.
      Interpolates between two scalars `y` and `z` using a gradient `a` that
      takes `x <-> y` and `z <-> w` into account in order to offer better
      continuity between segments. Check `LinearInerpolation` for more details.
**/
T CubicInterpolation(T)(T x, T y, T z, T w, float a) pure nothrow if (__traits(isScalar, T)) {
	a = Clamp(a, 0f, 1f);
	// Use slope between last and next point as derivative at current point
	T cx = cast(T)(-0.5*x + 1.5*y - 1.5*z + 0.5*w);
	T cy = cast(T)(x - 2.5*y + 2*z - 0.5*w);
	T cz = cast(T)(-0.5*x + 0.5*z);
	T cw = y;
	return cast(T)(cx*a*a*a + cy*a*a + cz*a + cw);
}
unittest {
	assert(__traits(compiles, CubicInterpolation(0, 1, 2, 3, 0.5f)));
	assert(__traits(compiles, CubicInterpolation(0f, 1f, 2f, 3f, 0.5f)));
}

/** Hermite interpolation on scalar elements as described by GLSL smoothstep.
      Interpolates between `x` and `y` using gradient `a` that allows
        smooth transitions as the gradient approaches `1` or `0`. See
        `LinearInterpolation` for more details.
**/
T HermiteInterpolation(T)(T x, T y, float a) pure nothrow if (__traits(isScalar, T)) {
	T t = cast(T)Clamp((a - x)/(y - x), 0f, 1f);
	return t*t*cast(T)(3f - 2f*t);
}
/// Alias to GLSL name for hermite interpolation
alias Smoothstep = HermiteInterpolation;
unittest {
	assert(__traits(compiles, Smoothstep(0, 1, 0.5f)));
	assert(__traits(compiles, Smoothstep(0f, 1f, 0.5f)));
}

/** Hermite interpolation on scalar elements. Similar to `CubicInterpolation`
      except that you have control over the tension (tightening of the
      curvature) and bias (twists the curve about known points).
  Params:
    Tension = any value from -1 to 1. -1 is low tension, 1 is high tension
    Bias = any value from -1 to 1. 0 is no bias, -1 is biased towards first,
           segment, 1 is biased towards the last segment
**/
T HermiteInterpolation(T)(T x, T y, T z, T w, float a, float tension, float bias) pure nothrow if (__traits(isScalar, T)) {
	a = Clamp(a, 0f, 1f);
	float a2 = a*a, a3 = a2*a;
	tension = (1f - tension)/2f;

	float m_y = (y-z)*(1f+bias)*tension + (z-y)*(1f-bias)*tension;
	float m_z = (z-y)*(1f+bias)*tension + (w-z)*(1f-bias)*tension;
	float a_x =  2f*a3 - 3f*a2 + 1f;
	float a_y =     a3 - 2f*a2 + a;
	float a_z =     a3 -    a2;
	float a_w = -2f*a3 + 3f*a2;

	return cast(T)(a_x*y + a_y*m_y + a_z*m_z + a_w*z);
}

unittest {
	assert(__traits(compiles, HermiteInterpolation(0, 1, 2, 3, 0.5f, 0.2f, 0f)));
	assert(__traits(compiles, HermiteInterpolation(0f, 1f, 2f, 3f, 0.5f, 0.2f, 0f)));
}

/**
	Smoothstep Interpolation.
	Params:
		Low = the low value
		High = the high value
		X = the point between the values
	Returns:
		A smoothed value.
**/
T SmoothStepInterpolation(T)(T low, T high, T x) {
	T o = Clamp((x-low) / (high - low), 0.0f, 1.0f);
	return o * o * ( 3 - 2 * o);
}

unittest {
	assert(__traits(compiles, SmoothStepInterpolation(0f, 1f, 0.5f)));
	assert(__traits(compiles, SmoothStepInterpolation(1f, 0f, 0.5f)));
}
