module polyplex.core.render.camera;
import polyplex.math;
public class Camera {
	protected Vector3 position;
	protected Quaternion rotation;
	protected float zoom;
	protected Matrix4x4 matrix;

	public @property Matrix4x4 Matrix() { return this.matrix; }

	public void Update() {
		this.matrix = Matrix4x4.identity.Scale(zoom, zoom, zoom).Translate(position) * rotation.to_matrix!(4,4)();
	}
}

public class Camera3D : Camera {

	this(Vector3 position, Quaternion rotation = Quaternion.identity, float zoom = 1f) {
		this.position = position;
		this.rotation = rotation;
		this.zoom = zoom;
		Update();
	}

	public @property Vector3 Position() { return position; }
	public @property void Position(Vector3 position) { this.position = position; Update(); }

	public @property Quaternion Rotation() { return rotation; }
	public @property void Rotation(Quaternion rotation) { this.rotation = rotation; Update(); }

	public @property float Zoom() { return zoom; }
	public @property void Zoom(float zoom) { this.zoom = zoom; Update(); }
}

public class Camera2D : Camera {

	this(Vector2 position, float rotation = 0, float zoom = 1f) {
		this.position = Vector3(position.X, position.Y, -1);
		this.rotation = Quaternion.identity.RotateZ(rotation);
		this.zoom = zoom;
		Update();
	}

	public @property Vector2 Position() { return Vector2(position.X, position.Y); }
	public @property void Position(Vector2 position) { this.position = Vector3(position.X, position.Y, -1); Update(); }

	public @property float Rotation() { return rotation.Z; }
	public @property void Rotation(float rotation) { this.rotation = Quaternion.identity.RotateZ(rotation); Update(); }

	public @property float Zoom() { return zoom; }
	public @property void Zoom(float zoom) { this.zoom = zoom; Update(); }
}