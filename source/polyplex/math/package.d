module polyplex.math;

public static import Mathf = polyplex.math.mathf;
public import polyplex.math.rectangle;

version(GL_MATH) {
	public import polyplex.math.glmath;
} else {
	public import polyplex.math.simplemath;
}
