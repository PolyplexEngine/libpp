module polyplex.math;

public static import Mathf = polyplex.math.mathf;
public import polyplex.math.rectangle;

version(glmath) {
	public import polyplex.math.glmath;
} else version(simplemath) {
	public import polyplex.math.simplemath;
}
