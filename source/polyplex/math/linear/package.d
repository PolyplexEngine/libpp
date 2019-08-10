module polyplex.math.linear;

public import polyplex.math.linear.vectors;
public import polyplex.math.linear.matrix2x2;
public import polyplex.math.linear.matrix3x3;
public import polyplex.math.linear.matrix4x4;
public import polyplex.math.linear.quaternion;
public import polyplex.math.linear.transform;

// Unit tests
unittest {
	// ================ Vectors ===================
	
	// Test IsVector
	assert(IsVector!(Vector2));
	assert(IsVector!(Vector2i));
	assert(IsVector!(Vector3));
	assert(IsVector!(Vector3i));
	assert(IsVector!(Vector4));
	assert(IsVector!(Vector4i));
	assert(!IsVector!(float));

	// ================ Vector2 ===================
 
	// Test IsVector2T
	assert(IsVector2T!(Vector2));
	assert(IsVector2T!(Vector2i));
	
	assert(!IsVector2T!(Vector4));
	assert(!IsVector2T!(float));
	assert(!IsVector2T!(string));

	// Test Construct
	assert(Vector2(1) == Vector2(1, 1));
	assert(Vector2(1, 0) == Vector2(1, 0));

	// Test Add
	assert((Vector2(1)+Vector2(2, 3)) == Vector2(3, 4));
	assert((Vector2(1)+Vector2(2, 32)) != Vector2(3, 4));

	// Test Subtract
	assert((Vector2(32)-Vector2(1, 1)) == Vector2(31, 31));
	assert((Vector2(32)-Vector2(0, 0)) != Vector2(31, 31));

	// ================ Vector3 ===================

	// Test IsVector2T
	assert(IsVector3T!(Vector3));
	assert(IsVector3T!(Vector3i));

	// ================ Vector4 ===================

	// Test IsVector4T
	assert(IsVector4T!(Vector4));
	assert(IsVector4T!(Vector4i));
	
	// =============== Matricies ==================

	// Test Matrix4x4
	Matrix4x4 mt4 = Matrix4x4.Identity;
	Matrix4x4 mt4_o = Matrix4x4([
		[1, 0, 0, 2],
		[0, 1, 0, 5],
		[0, 0, 1, 3],
		[0, 0, 0, 1]
	]);

	Matrix4x4 orth_mat = Matrix4x4.Orthographic(-1f, 1f, -1f, 1f, -1f, 1f);
	Matrix4x4 comp_orth = Matrix4x4([
		[1f, 0f, 0f, -0f],
		[0f, 1f, 0f, -0f],
		[0f, 0f, -1f, -0f],
		[0f, 0f, 0f, 1f]
	]);
	assert(orth_mat == comp_orth, "orth_mat != comp_orth \n" ~ orth_mat.ToString ~ ",\n" ~ comp_orth.ToString);
}
