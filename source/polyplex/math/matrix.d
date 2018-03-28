module polyplex.math.matrix;
import polyplex.math.vector;

private bool ProperMatrixBinaryOperation(string op) {
	return op == "/" || op == "*" || op == "+" || op == "-";
}

private bool ProperMatrixUnaryOperation(string op) {
	return op == "-" || op == "+";
}

private template GenericMatrixOperatorFunctionsMixin(T, int Rows, int Columns) {
	private alias GMatrix = typeof(this);

	public GMatrix opBinary(string op)(T rhs) pure const nothrow if ( ProperMatrixBinaryOperation(op) ) {
		GMatrix temp_matrix;

		static foreach( x; 0 .. Rows ) {
			static foreach( y; 0 .. Columns ) {
				mixin(q{ temp_matrix.data[x][y] = this.data[x][y] %s rhs; }.format(op));
			}
		}
		return temp_matrix;
	}

	public GMatrix opBinaryRight(string op)(T lhs) pure const nothrow if ( ProperMatrixBinaryOperation(op) ) {
		GMatrix temp_matrix;

		static foreach( x; 0 .. Rows ) {
			static foreach( y; 0 .. Columns ) {
				mixin(q{ temp_matrix.data[x][y] = lhs %s this.data[x][y]; }.format(op));
			}
		}
		return temp_matrix;
	}

	public GMatrix opBinary(string op)(T rhs) pure const nothrow if ( ProperMatrixBinaryOperation(op) ) {
		GMatrix temp_matrix;

		static foreach( x; 0 .. Rows ) {
			static foreach( y; 0 .. Columns ) {
				mixin(q{ temp_matrix.data[x][y] = this.data[x][y] %s rhs.data[x][y]; }.format(op));
			}
		}
		return temp_matrix;
	}

	public GMatrix opUnary(string op)(T rhs) pure const nothrow if ( ProperMatrixUnaryOperation(op) ) {
		GMatrix temp_matrix;

		static foreach( x; 0 .. Rows ) {
			static foreach( y; 0 .. Columns ) {
				mixin(q{ temp_matrix.data[x][y] = %s this.data[x][y]; }.format(op));
			}
		}
		return temp_matrix;
	}

	public GMatrix opOpAssign(string op, U)(U rhs) if ( __traits(isArithmetic, U) || IsMatrix!U ) {
		mixin(q{ this = this %s rhs; }.format(op));
	}
}

private template GenericMatrixDefaultFunctionsMixing(T, int Rows, int Columns) {
	private alias GMatrix = typeof(this);

	public static GMatrix Identity ( ) pure nothrow { return GMatrix(); }

	public GMatrix Transpose() pure const nothrow {
		GMatrix temp = this;
		static foreach( x; 0 .. Rows ) {
			static foreach ( y; 0 .. Rows ) {
				temp.data[x][y] = this.data[y][x];
			}
		}
		return temp;
	}
}

private template GenericMatrixMixin(int _Rows, int _Columns) {
	static assert(_Rows >= 2 && _Rows <= 4, "The rows of a matrix needs to be 2, 3 or 4.");
	static assert(_Columns >= 2 && _Columns <= 4, "The rows of a matrix needs to be 2, 3 or 4.");
	
	public immutable static size_t Rows = _Rows;
	public immutable static size_t Columns = _Columns;

	public enum IsSquare(U) = (U.Rows == U.Columns);

	mixin GenericMatrixOperatorFunctionsMixin!(float, Rows, Columns);
	mixin GenericMatrixDefaultFunctionsMixing!(float, Rows, Columns);

	public inout(float)* ptr() pure inout nothrow { return data[0].ptr; }
}

struct Matrix(int Rows, int Columns);

enum IsMatrix(T) = is(T : Matrix!U, U...);

alias Matrix2x2 = Matrix!(2, 2);
alias Matrix3x3 = Matrix!(3, 3);
alias Matrix4x4 = Matrix!(4, 4);
alias mat2x2 = Matrix2x2;
alias mat3x3 = Matrix3x3;
alias mat4x4 = Matrix4x4;

struct Matrix(int _Rows:2, int _Columns:2) {
	public float[2][2] data = [
		[1, 0], 
		[0, 1]
	];

	mixin GenericMatrixMixin!(2, 2);

}

struct Matrix(int _Rows:3, int _Columns:3) {
	public float[3][3] data = [
		[1, 0, 0],
		[0, 1, 0],
		[0, 0, 1]
	];

	mixin GenericMatrixMixin!(3, 3);
}

struct Matrix(int _Rows:4, int _Columns:4) {
	public float[4][4] data = [
		[1, 0, 0, 0],
		[0, 1, 0, 0],
		[0, 0, 1, 0],
		[0, 0, 0, 1]
	];

	mixin GenericMatrixMixin!(4, 4);
}