module polyplex.utils.mathutils;

class Math {
	public static double Min(double a, double b) {
		if (a < b) return a;
		return b;
	}

	public static double Max(double a, double b) {
		if (a > b) return a;
		return b;
	}

	public static int Min(int a, int b) { return cast(int)Min(cast(double)a, cast(double)b); }
}