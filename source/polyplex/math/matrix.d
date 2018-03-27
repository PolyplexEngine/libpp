module polyplex.math.matrix;

public class Matrix {
	public abstract @property float[] GlValues();
}

public class Matrix4x4 : Matrix {
	private float[4][4] matrix_values;
	
	public override @property float[] GlValues() {
		return [
			matrix_values[0][0], matrix_values[0][1], matrix_values[0][2], matrix_values[0][3],
			matrix_values[1][0], matrix_values[1][1], matrix_values[1][2], matrix_values[1][3],
			matrix_values[2][0], matrix_values[2][1], matrix_values[2][2], matrix_values[2][3],
			matrix_values[3][0], matrix_values[3][1], matrix_values[3][2], matrix_values[3][3],
		];
	}

	public static @property Matrix4x4 Identity() {
		return new Matrix4x4([
			[1, 0, 0, 0],
			[0, 1, 0, 0],
			[0, 0, 1, 0],
			[0, 0, 0, 1]
		]);
	}

	this(float[4][4] input_matrix) {
		this.matrix_values = input_matrix;
	}

	this () {
		this.matrix_values = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
	}

	public Matrix4x4 Transpose() {
		Matrix4x4 mat;
		for (int x = 0; x < 4; x++) {
			for (int y = 0; y < 4; y++) {
				mat.matrix_values[x][y] = matrix_values[y][x];
			}
		}
	}

	public void Scale(int x, int y, int z) {

	}
}

alias mat4x4 = Matrix4x4;