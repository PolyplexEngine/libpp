module polyplex.math.simplemath.transform;
import polyplex.math.simplemath.matrix4x4;
import polyplex.math.simplemath.vectors;
import polyplex.math.simplemath.quaternion;

public class Transform {
	private Transform parent;
	public Vector3 LocalScale;
	public Quaternion LocalRotation;
	public Vector3 LocalPosition;

	public Transform LocalTransform() {
		return new Transform(LocalScale, LocalRotation, LocalPosition);
	}

	this(Transform parent) {
		this.parent = parent;
		LocalScale = Vector3.Zero;
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

	private Matrix4x4 trs() {
		return ltrans * lrot * lscale;
	}

	public Vector3 Scale() {
		if (parent is null) return LocalScale;
		return (parent.trs*trs).ToScaling();
	}

	public Quaternion Rotation() {
		if (parent is null) return LocalRotation;
		return Rotation.FromMatrix(parent.trs*trs);
	}

	public Vector3 Position() {
		if (parent is null) return LocalPosition;
		return (parent.trs*trs).ToTranslation();
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
	private Transform2D parent;
	public Vector2 LocalScale;
	public Quaternion LocalRotation;
	public Vector2 LocalPosition;

	public Transform2D LocalTransform() {
		return new Transform2D(LocalScale, LocalRotation, LocalPosition);
	}

	this(Transform2D parent) {
		this.parent = parent;
		LocalScale = Vector2.Zero;
		LocalRotation = Quaternion.Identity;
		LocalPosition = Vector2.Zero;
	}


	this(Vector2 scale, Quaternion rotation, Vector2 position) {
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
		return Matrix4x4.FromQuaternion(LocalRotation);
	}

	private Matrix4x4 ltrans() {
		return Matrix4x4.Translation(Vector3(LocalPosition));
	}

	private Matrix4x4 trs() {
		return ltrans * lrot * lscale;
	}

	public Vector2 Scale() {
		if (parent is null) return LocalScale;
		return Vector2((parent.trs*trs).ToScaling());
	}

	public Quaternion Rotation() {
		if (parent is null) return LocalRotation;
		return Rotation.FromMatrix(parent.trs*trs);
	}

	public Vector2 Position() {
		if (parent is null) return LocalPosition;
		return Vector2((parent.trs*trs).ToTranslation());
	}

	public void Rotate(float amount) {
		LocalRotation.Rotate(Vector3.Forward, amount);
	}

	public Vector2 Up() {
		return Vector2(Rotation.UpDirection);
	}

	public Vector2 Down() {
		Vector2 up = Up;
		return Vector2(-up.X, -up.Y);
	}

	public Vector2 Left() {
		return Vector2(Rotation.LeftDirection);
	}
	
	public Vector2 Right() {
		Vector2 left = Left;
		return Vector2(-left.X, -left.Y);
	}
}