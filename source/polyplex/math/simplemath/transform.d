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
		LocalScale = Vector3.Zero;
		LocalRotation = Quaternion.Identity;
		LocalPosition = Vector3.Zero;
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
		return Vector3.Up;
	}

	public Vector3 Down() {
		return Vector3.Down;
	}

	public Vector3 Forward() {
		return Vector3.Forward;
	}
	
	public Vector3 Back() {
		return Vector3.Back;
	}

	public Vector3 Left() {
		return Vector3.Left;
		
	}
	
	public Vector3 Right() {
		return Vector3.Right;
		
	}
}