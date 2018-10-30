module polyplex.math.simplemath.transform;
import polyplex.math.simplemath.matrix4x4;
import polyplex.math.simplemath.vectors;
import polyplex.math.simplemath.quaternion;

public class Transform {
	public Transform Parent;
	public Vector3 LocalScale;
	public Quaternion LocalRotation;
	public Vector3 LocalPosition;

	public Transform LocalTransform() {
		return new Transform(LocalScale, LocalRotation, LocalPosition);
	}

	this(Transform parent) {
		this.Parent = parent;
		LocalScale = Vector3.One;
		LocalRotation = Quaternion.Identity;
		LocalPosition = Vector3.Zero;
	}

	this(Vector3 scale, Quaternion rotation, Vector3 position) {
		this(null);
		LocalScale = scale;
		LocalRotation = rotation;
		LocalPosition = position;
	}

	this() {
		this(null);
	}

	private Matrix4x4 lscale() {
		return Matrix4x4.Scaling(LocalScale);
	}

	private Matrix4x4 lrot() {
		return Matrix4x4.FromQuaternion(LocalRotation);
	}

	private Matrix4x4 ltrans() {
		return Matrix4x4.Translation(LocalPosition);
	}

	public Matrix4x4 TRS() {
		if (Parent is null) 
			return (ltrans * lrot * lscale);
		return Parent.TRS*(ltrans * lrot * lscale);
	}

	public Vector3 Scale() {
		if (Parent is null) return LocalScale;
		return (TRS).ToScaling();
	}

	public Quaternion Rotation() {
		if (Parent is null) return LocalRotation;
		return Rotation.FromMatrix(TRS);
	}

	public Vector3 Position() {
		if (Parent is null) return LocalPosition;
		return TRS.ToTranslation();
	}

	public Vector3 Up() {
		return Rotation.UpDirection;
	}

	public Vector3 Down() {
		Vector3 up = Up;
		return Vector3(-up.X, -up.Y, -up.Z);
	}

	public Vector3 Forward() {
		return Rotation.ForwardDirection;
	}
	
	public Vector3 Back() {
		Vector3 forward = Forward;
		return Vector3(-forward.X, -forward.Y, -forward.Z);
	}

	public Vector3 Left() {
		return Rotation.LeftDirection;
	}
	
	public Vector3 Right() {
		Vector3 left = Left;
		return Vector3(-left.X, -left.Y, -left.Z);
	}
}

public class Transform2D {
	public Transform2D Parent;
	public Vector2 LocalScale;
	public float LocalRotation;
	public Vector2 LocalPosition;

	public Transform2D LocalTransform() {
		return new Transform2D(LocalScale, LocalRotation, LocalPosition);
	}

	this(Transform2D parent) {
		this.Parent = parent;
		LocalScale = Vector2.One;
		LocalRotation = 0f;
		LocalPosition = Vector2.Zero;
	}


	this(Vector2 scale, float rotation, Vector2 position) {
		LocalScale = scale;
		LocalRotation = rotation;
		LocalPosition = position;
	}

	this() {
		this(null);
	}

	private Matrix4x4 lscale() {
		return Matrix4x4.Scaling(Vector3(LocalScale));
	}

	private Matrix4x4 lrot() {
		return Matrix4x4.RotationZ(this.LocalRotation);
	}

	private Matrix4x4 ltrans() {
		return Matrix4x4.Translation(Vector3(LocalPosition));
	}

	public Matrix4x4 TRS() {
		if (Parent is null) 
			return (ltrans * lrot * lscale);
		return Parent.TRS*(ltrans * lrot * lscale);
	}

	public Matrix4x4 MatrixScale() {
		return lscale;
	}

	public Matrix4x4 MatrixRotation() {
		return lrot;
	}

	public Matrix4x4 MatrixPosition() {
		return ltrans;
	}

	public Vector2 Scale() {
		if (Parent is null) return LocalScale;
		return Vector2(TRS.ToScaling());
	}

	public float Rotation() {
		if (Parent is null) return LocalRotation;
		return Parent.Rotation+LocalRotation;
	}

	public Vector2 Position() {
		if (Parent is null) return LocalPosition;
		return Vector2(TRS.ToTranslation());
	}

	public void Rotate(float amount) {
		LocalRotation = amount;
	}

	public Vector2 Up() {
		return Vector2(
			Vector2.Up.X * Mathf.Cos(Rotation) - Vector2.Up.Y * Mathf.Sin(Rotation),
			Vector2.Up.X * Mathf.Sin(Rotation) + Vector2.Up.Y * Mathf.Cos(Rotation)
		);
	}

	public Vector2 Down() {
		Vector2 up = Up;
		return Vector2(-up.X, -up.Y);
	}

	public Vector2 Left() {
		return Vector2(
			Vector2.Left.X * Mathf.Cos(Rotation) - Vector2.Left.Y * Mathf.Sin(Rotation),
			Vector2.Left.X * Mathf.Sin(Rotation) + Vector2.Left.Y * Mathf.Cos(Rotation)
		);
	}
	
	public Vector2 Right() {
		Vector2 left = Left;
		return Vector2(-left.X, -left.Y);
	}
}