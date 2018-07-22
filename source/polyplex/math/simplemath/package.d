module polyplex.math.simplemath;

public import polyplex.math.simplemath.vector2;
public import polyplex.math.simplemath.vector3;
public import polyplex.math.simplemath.vector4;
public import polyplex.math.simplemath.matrix2x2;
public import polyplex.math.simplemath.matrix3x3;
public import polyplex.math.simplemath.matrix4x4;
public import polyplex.math.simplemath.quaternion;


enum IsVector(T) = (IsVector2T!T || IsVector3T!T || IsVector4T!T);

// Unit tests
unittest {
	// ================ Vector2 ===================
	assert(IsVector2T!(Vector2i));
}
