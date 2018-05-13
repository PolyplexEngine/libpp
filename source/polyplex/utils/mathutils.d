module polyplex.utils.mathutils;

class Math {
	/**
		Returns the smallest of the two specified doubles.
	*/
	public static double Min(double a, double b) {
		if (a < b) return a;
		return b;
	}

	/**
		Returns the biggest of the two specified doubles.
	*/
	public static double Max(double a, double b) {
		if (a > b) return a;
		return b;
	}

	/**
		Returns the smallest of the two specified integers.
	*/
	public static int Min(int a, int b) { return cast(int)Min(cast(double)a, cast(double)b); }

	/**
		Returns the biggest of the two specified integers.
	*/
	public static int Max(int a, int b) { return cast(int)Max(cast(double)a, cast(double)b); }
}