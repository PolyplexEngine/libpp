module polyplex.math.matrix;
import polyplex.math;
import std.conv;
import std.stdio;

struct Matrix(int Dimensions) {
	alias GMatrix = typeof(this);
	float[Dimensions][Dimensions] data;

	this(float[Dimensions][Dimensions] d) {
		this.data = d;
	}

	private static float[Dimensions][Dimensions] fill_data() {
		float[Dimensions][Dimensions] dat;
		foreach ( x; 0 .. Dimensions ) {
			foreach ( y; 0 .. Dimensions ) {
				dat[x][y] = 0;
			}
		}
		return dat;
	}

	public static GMatrix Identity() {
		float[Dimensions][Dimensions] data = fill_data();
		foreach ( i; 0 .. Dimensions ) {
			data[i][i] = 1f;
		}
		return GMatrix(data);
	}

	static if(Dimensions >= 3)
	public static GMatrix Scale(Vector!(float, Dimensions-1) scale_vec) {
		float[Dimensions][Dimensions] dims = GMatrix.Identity.data;
		foreach( x; 0 .. Dimensions-1 ) {
			foreach( y; 0 .. Dimensions-1 ) {
				if (x == y) dims[x][y] = scale_vec.data[y];
				else dims[x][y] = 0;
			}
		}
		dims[Dimensions-1][Dimensions-1] = 1;
		return GMatrix(dims);
	}

	static if(Dimensions >= 3)
	public static GMatrix RotateX(float x_rot) {
		float[Dimensions][Dimensions] dims = GMatrix.Identity.data;
		dims[1][1] = Mathf.Cos(x_rot);
		dims[1][2] = -Mathf.Sin(x_rot);
		dims[2][1] = Mathf.Sin(x_rot);
		dims[2][2] = Mathf.Cos(x_rot);
		return GMatrix(dims);
	}

	static if(Dimensions >= 3)
	public static GMatrix RotateY(float y_rot) {
		float[Dimensions][Dimensions] dims = GMatrix.Identity.data;
		dims[0][0] = Mathf.Cos(y_rot);
		dims[2][0] = Mathf.Sin(y_rot);
		dims[2][0] = -Mathf.Sin(y_rot);
		dims[2][2] = Mathf.Cos(y_rot);
		return GMatrix(dims);
	}

	static if(Dimensions == 4)
	public static GMatrix RotateZ(float z_rot) {
		float[Dimensions][Dimensions] dims = GMatrix.Identity.data;
		dims[0][0] = Mathf.Cos(z_rot);
		dims[1][0] = -Mathf.Sin(z_rot);
		dims[0][1] = Mathf.Sin(z_rot);
		dims[1][1] = Mathf.Cos(z_rot);
		return GMatrix(dims);
	}

	static if (Dimensions == 2)
	public static GMatrix Rotate(float rot) {
		return GMatrix([
			[Mathf.Cos(rot), -Mathf.Sin(rot)],
			[Mathf.Sin(rot), Mathf.Cos(rot)]
		]);
	}

	static if (Dimensions == 4)
	public static GMatrix FromQuaternion(Quaternion quat) {
		float qx = quat.X;
		float qy = quat.Y;
		float qz = quat.Z;
		float qw = quat.w;
		float n = 2f/(qx*qx+qy*qy+qz*qz+qw*qw);
		qx *= n;
		qy *= n;
		qz *= n;
		qw *= n;
		return GMatrix([
			[1.0f - n*qy*qy - n*qz*qz, n*qx*qy - n*qz*qw, n*qx*qz + n*qy*qw, 0f],
			[n*qx*qy + n*qz*qw, 1f - n*qx*qx - n*qz*qz, n*qy*qz - n*qx*qw, 0f],
			[n*qx*qz - n*qy*qw, n*qy*qz + n*qx*qw, 1f - n*qx*qx - n*qy*qy, 0f],
			[0f, 0f, 0f, 1f]
		]);
	}
	
	public static GMatrix Translate(Vector!(float, Dimensions) trans_vec) {
		GMatrix out_matrix = GMatrix.Identity();
		for (int x = 0; x < Dimensions; x++) {
			out_matrix.data[x][x] = 1;
		}
		for (int x = 0; x < Dimensions; x++) {
			out_matrix.data[Dimensions-1][x] = trans_vec.data[x];
		}
		return out_matrix;
	}

	public GMatrix opBinary(string op: "*")(GMatrix other) pure nothrow {
		float[Dimensions][Dimensions] dim = fill_data();
		foreach ( row; 0 .. Dimensions ) {
			foreach ( column; 0 .. Dimensions ) {
				foreach ( i; 0 .. Dimensions ) {
					dim[row][column] += this.data[row][i] * other.data[i][column];
				}
			}
		}
		return GMatrix(dim);
	}

	static if(Dimensions >= 3)
	public static GMatrix Translate(Vector!(float, Dimensions-1) trans_vec) {
		GMatrix out_matrix = GMatrix.Identity();
		for (int x = 0; x < Dimensions; x++) {
			if (Dimensions == 4 && x == 3) {
				out_matrix.data[Dimensions-1][x] = 1;
			} else {
				out_matrix.data[Dimensions-1][x] = trans_vec.data[x];
			}
		}
		return out_matrix;
	}

	static if(Dimensions == 4)
	public static GMatrix Ortho(float left, float right, float top, float bottom, float znear, float zfar) {
		return GMatrix([
			[2.0f/(right-left), 0, 0, 0],
			[0, 2.0f/(top-bottom), 0, 0],
			[0, 0, 2.0f/(zfar-znear), 0],
			[-(right+left)/(right-left), -(top+bottom)/(top-bottom), -(zfar+znear)/(zfar-znear), 1f]
		]);
	}

	private static float[6] prepPerspective(float width, float height, float fov, float znear, float zfar) {
		float aspect = width/height;
		float top = znear * Mathf.Tan(Mathf.ToRadians(fov));
		float bottom = -top;
		float right = top * aspect;
		float left = -right;
		return [left, right, bottom, top, znear, zfar];
	}

	static if(Dimensions == 4)
	public static GMatrix Perspective(float width, float height, float fov, float znear, float zfar) {
		float[6] persp_data = prepPerspective(width, height, fov, znear, zfar);
		return perspective(persp_data[0], persp_data[1], persp_data[2], persp_data[3], persp_data[4], persp_data[5]);
	}

	static if(Dimensions == 4)
	private static GMatrix perspective(float left, float right, float bottom, float top, float near, float far) {
		return GMatrix([
			[(2f*near)/(right-left), 0, (right+left)/(right-left), 0],
			[0, (2f*near)/(top-bottom), -(2f*far*near)/(far-near), 0],
			[0, (top+bottom)/(top-bottom), -(far+near)/(far-near), 0],
			[0, 0, -1f, 0]
		]);
	}

	public GMatrix Transpose() pure const nothrow {
		GMatrix temp = this;
		static foreach( x; 0 .. Dimensions ) {
			static foreach ( y; 0 .. Dimensions ) {
				temp.data[x][y] = this.data[y][x];
			}
		}
		return temp;
	}

	public GMatrix Scale(Vector!(float, Dimensions) scale_vec) {
		return this * GMatrix.Scale(scale_vec);
	}

	static if (Dimensions >= 3)
	public GMatrix RotateX(float rot) {
		return this * GMatrix.RotateX(rot);
	}

	static if (Dimensions >= 3)
	public GMatrix RotateY(float rot) {
		return this * GMatrix.RotateY(rot);
	}

	static if (Dimensions >= 3)
	public GMatrix RotateZ(float rot) {
		return this * GMatrix.RotateZ(rot);
	}

	static if (Dimensions == 2)
	public GMatrix Rotate(float rot) {
		return this * GMatrix.Rotate(rot);
	}

	static if(Dimensions == 4)
	public GMatrix Rotate(Quaternion rot) {
		return this * GMatrix.FromQuaternion(rot);
	} 

	public string ToString() {
		string dim = "[";
		foreach( x; 0 .. Dimensions ) {
			dim ~= "\n\t[";
			foreach ( y; 0 .. Dimensions ) {
				dim ~= this.data[x][y].text;
				if (y != Dimensions-1) dim ~= ", ";
			}
			dim ~= "]";
			if (x != Dimensions-1) dim ~= ",";
		}
		return dim ~ "\n]";
	}
	
	/// Returns a pointer to the data container of this vector
	public inout(float)* ptr() pure inout nothrow { return data[0].ptr; }
}

alias Matrix4x4 = Matrix!4;
alias Matrix3x3 = Matrix!3;
alias Matrix2x2 = Matrix!2;

alias mat2x2 = Matrix2x2;
alias mat3x3 = Matrix3x3;
alias mat4x4 = Matrix4x4;

unittest {
	Matrix4x4 mt4 = Matrix4x4.Identity;
	Matrix4x4 mt4_o = Matrix4x4([
		[1, 0, 0, 2],
		[0, 1, 0, 5],
		[0, 0, 1, 3],
		[0, 0, 0, 1]
	]);
	assert((mt4*mt4_o) == mt4_o, "Matrix multiplication error! should be " ~ mt4_o.ToString);

	Matrix3x3 mt3 = Matrix3x3.Identity;
	Matrix3x3 mt3_o = Matrix3x3([
		[1, 0, 3],
		[0, 1, 2],
		[0, 0, 1]
	]);
	assert((mt3*mt3_o) == mt3_o, "Matrix multiplication error! should be " ~ mt3_o.ToString);

	Matrix2x2 mt2 = Matrix2x2.Identity;
	Matrix2x2 mt2_o = Matrix2x2([
		[1, 2],
		[0, 1],
	]);
	assert((mt2*mt2_o) == mt2_o, "Matrix multiplication error! should be " ~ mt3_o.ToString);
}