module polyplex.math.simplemath.matrix4x4;
import polyplex.math.simplemath;
import polyplex.math;
import std.conv;

// TODO: Redo implementation
public struct Matrix4x4 {
	private float[4][4] data;

	private static float[4][4] clear(float val) {
		float[4][4] dat;
		foreach ( x; 0 .. 4 ) {
			foreach ( y; 0 .. 4 ) {
				dat[x][y] = val;
			}
		}
		return dat;
	}

	public static Matrix4x4 Identity() {
		float[4][4] data = clear(0);
		foreach ( i; 0 .. 4 ) {
			data[i][i] = 1f;
		}
		return Matrix4x4(data);
	}

	public static Matrix4x4 Scaling(Vector3 scale_vec) {
		Matrix4x4 i = Matrix4x4.Identity;
		i.data[0][0] = scale_vec.X;
		i.data[1][1] = scale_vec.Y;
		i.data[2][2] = scale_vec.Z;
		return i;
	}

	/*public static Matrix4x4 Scaling(Vector3 scale_vec) {
		float[4][4] dims = Matrix4x4.Identity.data;
		foreach( x; 0 .. 4-1 ) {
			foreach( y; 0 .. 4-1 ) {
				if (x == y) dims[x][y] = scale_vec.data[x];
				else dims[x][y] = 0;
			}
		}
		dims[4-1][4-1] = 1;
		return Matrix4x4(dims);
	}*/

	public static Matrix4x4 RotationX(float x_rot) {
		float[4][4] dims = Matrix4x4.Identity.data;
		dims[1][1] = Mathf.Cos(x_rot);
		dims[1][2] = Mathf.Sin(x_rot);
		dims[2][1] = -Mathf.Sin(x_rot);
		dims[2][2] = Mathf.Cos(x_rot);
		return Matrix4x4(dims);
	}

	public static Matrix4x4 RotationY(float y_rot) {
		float[4][4] dims = Matrix4x4.Identity.data;
		dims[0][0] = Mathf.Cos(y_rot);
		dims[0][2] = -Mathf.Sin(y_rot);
		dims[2][0] = Mathf.Sin(y_rot);
		dims[2][2] = Mathf.Cos(y_rot);
		return Matrix4x4(dims);
	}

	public static Matrix4x4 RotationZ(float z_rot) {
		float[4][4] dims = Matrix4x4.Identity.data;
		dims[0][0] = Mathf.Cos(z_rot);
		dims[1][0] = Mathf.Sin(z_rot);
		dims[0][1] = -Mathf.Sin(z_rot);
		dims[1][1] = Mathf.Cos(z_rot);
		return Matrix4x4(dims);
	}

	public static Matrix4x4 FromQuaternion(Quaternion quat) {
		float qx = quat.X;
		float qy = quat.Y;
		float qz = quat.Z;
		float qw = quat.W;
		float n = 2f/(qx*qx+qy*qy+qz*qz+qw*qw);
		qx *= n;
		qy *= n;
		qz *= n;
		qw *= n;
		return Matrix4x4([
			[1.0f - n*qy*qy - n*qz*qz, n*qx*qy - n*qz*qw, n*qx*qz + n*qy*qw, 0f],
			[n*qx*qy + n*qz*qw, 1f - n*qx*qx - n*qz*qz, n*qy*qz - n*qx*qw, 0f],
			[n*qx*qz - n*qy*qw, n*qy*qz + n*qx*qw, 1f - n*qx*qx - n*qy*qy, 0f],
			[0f, 0f, 0f, 1f]
		]);
	}

	public static Matrix4x4 Translation(Vector3 trans_vec) {		
		return Matrix4x4([
			[1f, 0f, 0f, trans_vec.X],
			[0f, 1f, 0f, trans_vec.Y],
			[0f, 0f, 1f, trans_vec.Z],
			[0f, 0f, 0f, 1f]
		]);
	}

	public static Matrix4x4 Orthographic(float left, float right, float bottom, float top, float znear, float zfar) {
		return Matrix4x4([
			[2/(right-left), 0f, 0f, -(right+left)/(right-left)],
			[0f, 2/(top-bottom), 0f, -(top+bottom)/(top-bottom)],
			[0f, 0f, -2/(zfar-znear), -(zfar+znear)/(zfar-znear)],
			[0f, 0f, 0f, 1f]
		]);
	}

	public static Matrix4x4 OrthographicInverse(float left, float right, float bottom, float top, float znear, float zfar) {
		return Matrix4x4([
			[(right-left)/2f, 0, 0, 0],
			[0, (top-bottom)/2f, 0, 0],
			[0, 0, (zfar-znear)/-2f, 0],
			[(right+left)/2f, (top+bottom)/2f, (zfar+znear)/2f, 1f]
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

	public static Matrix4x4 Perspective(float width, float height, float fov, float znear, float zfar) {
		float[6] persp_data = prepPerspective(width, height, fov, znear, zfar);
		return perspective(persp_data[0], persp_data[1], persp_data[2], persp_data[3], persp_data[4], persp_data[5]);
	}

	private static Matrix4x4 perspective(float left, float right, float bottom, float top, float near, float far) {
		return Matrix4x4([
			[(2f*near)/(right-left), 0, (right+left)/(right-left), 0],
			[0, (2f*near)/(top-bottom), -(2f*far*near)/(far-near), 0],
			[0, (top+bottom)/(top-bottom), -(far+near)/(far-near), 0],
			[0, 0, -1f, 0]
		]);
	}

	public Matrix4x4 opBinary(string op: "*")(Matrix4x4 other) {
		float[4][4] dim = clear(0);
		foreach ( row; 0 .. 4 ) {
			foreach ( column; 0 .. 4 ) {
				foreach ( i; 0 .. 4 ) {
					dim[row][column] += this.data[row][i] * other.data[i][column];
				}
			}
		}
		return Matrix4x4(dim);
	}

	public Matrix4x4 Transpose() pure const nothrow {
		Matrix4x4 temp = this;
		static foreach( x; 0 .. 4 ) {
			static foreach ( y; 0 .. 4 ) {
				temp.data[x][y] = this.data[y][x];
			}
		}
		return temp;
	}

	public Matrix4x4 Translate (Vector3 trans_vec) {
		this = Matrix4x4.Translation(trans_vec) * this;
		return this;
	}

	public Matrix4x4 Scale(Vector3 scale_vec) {
		this = Matrix4x4.Scaling(scale_vec) * this;
		return this;
	}

	public Matrix4x4 RotateX(float rot) {
		this = Matrix4x4.RotationX(rot) * this;
		return this;
	}

	public Matrix4x4 RotateY(float rot) {
		return Matrix4x4.RotationY(rot) * this;
	}

	public Matrix4x4 RotateZ(float rot) {
		return Matrix4x4.RotationZ(rot) * this;
	}

	public Matrix4x4 Rotate(Quaternion rot) {
		return Matrix4x4.FromQuaternion(rot) * this;
	} 

	public string ToString() {
		string dim = "[";
		foreach( x; 0 .. 4 ) {
			dim ~= "\n\t[";
			foreach ( y; 0 .. 4 ) {
				dim ~= this.data[x][y].text;
				if (y != 4-1) dim ~= ", ";
			}
			dim ~= "]";
			if (x != 4-1) dim ~= ",";
		}
		return dim ~ "\n]";
	}

	/**
		Pointer to the underlying array data.
	*/
	public float* ptr() { return data[0].ptr; }
}
