module polyplex.math.linear.matrix3x3;

public class Matrix3x3 {
	private float[3][3] data;

	/**
		Pointer to the underlying array data.
	*/
	public float* ptr() { return data[0].ptr; }
}
