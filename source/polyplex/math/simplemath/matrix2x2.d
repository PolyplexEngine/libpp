module polyplex.math.simplemath.matrix2x2;

public class Matrix2x2 {
	private float[2][2] data;

	/**
		Pointer to the underlying array data.
	*/
	public float* ptr() { return data[0].ptr; }
}
