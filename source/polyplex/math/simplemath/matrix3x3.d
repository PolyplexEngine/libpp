module polyplex.math.simplemath.matrix3x3;

public struct Matrix3x3 {
	private float[3][3] data;

	/**
		Pointer to the underlying array data.
	*/
	public float* ptr() { return data[0].ptr; }
}
