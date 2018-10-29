module polyplex.math.simplemath.transform;
import polyplex.math.simplemath.matrix4x4;
import polyplex.math.simplemath.vectors;
import polyplex.math.simplemath.quaternion;

public class Transform {
	private Transform parent;
	public Vector3 LocalScale;
	public Quaternion LocalRotation;
	public Vector3 LocalPosition;

	this(Transform parent) {
		this.parent = parent;
		LocalScale = Vector3.Zero;
		LocalRotation = Quaternion.Identity;
		LocalPosition = Vector3.Zero;
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
		return Rotation.Rotate(Vector3.Up, 0);
	}

	public Vector3 Down() {
		return Rotation.Rotate(Vector3.Down, 0);
	}

	public Vector3 Forward() {
		return Rotation.Rotate(Vector3.Forward, 0);
	}
	
	public Vector3 Back() {
		return Rotation.Rotate(Vector3.Back, 0);
	}

	public Vector3 Left() {
		return Rotation.Rotate(Vector3.Left, 0);
	}
	
	public Vector3 Right() {
		return Rotation.Rotate(Vector3.Right, 0);
	}
}

public class Transform2D {
	private Transform2D parent;
	public Vector2 LocalScale;
	public Quaternion LocalRotation;
	public Vector2 LocalPosition;

	this(Transform2D parent) {
		this.parent = parent;
		LocalScale = Vector2.Zero;
		LocalRotation = Quaternion.Identity;
		LocalPosition = Vector2.Zero;
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
		return Vector2(Rotation.Rotate(Vector3.Up, 0));
	}

	public Vector2 Down() {
		return Vector2(Rotation.Rotate(Vector3.Down, 0));
	}

	public Vector2 Left() {
		return Vector2(Rotation.Rotate(Vector3.Left, 0));;
	}
	
	public Vector2 Right() {
		return Vector2(Rotation.Rotate(Vector3.Right, 0));
	}
}