module polyplex.core.render.camera;
import polyplex.math;
import std.stdio;

/**
	A basis of a camera.
*/
public class Camera {
	protected Matrix4x4 matrix;
	protected float znear;
	protected float zfar;

	public @property Matrix4x4 Matrix() { Update(); return this.matrix; }
	public abstract void Update();
	public abstract Matrix4x4 Project(float width, float height);
}

/**
	A basic 3D camera, optimized for use in 3D environments.
*/
public class Camera3D : Camera {
	private float fov;
	public Vector3 Position;
	public Quaternion Rotation;
	public float Zoom;


	this(Vector3 position, Quaternion rotation = Quaternion.identity, float zoom = 1f, float near = 0.1f, float far = 100f, float fov = 90f) {
		this.Position = position;
		this.Rotation = rotation;
		this.Zoom = zoom;

		this.znear = near;
		this.zfar = far;
		this.fov = fov;
		Update();
	}

	public override void Update() {
		this.matrix = Matrix4x4.identity* Rotation.to_matrix!(4,4)().Translate(Position).Scale(Zoom, Zoom, Zoom);
	}

	public override Matrix4x4 Project(float width, float height) {
		return Matrix4x4.Perspective(width, height, this.fov, znear, zfar);
	}
}

public class Camera2D : Camera {
	public Vector2 Position;
	public float Rotation;
	public float Zoom;
	public Vector2 Origin;

	this(Vector2 position, float rotation = 0, float zoom = 1f, float near = 0.1f, float far = 100f) {
		this.Position = Vector3(position.X, position.Y, -1);
		this.Rotation = rotation; 
		this.Zoom = zoom;
		this.Origin = Vector2(0, 0);

		this.znear = near;
		this.zfar = far;
		this.matrix = Matrix4x4.identity;
		Update();
	}

	public override void Update() {
		this.matrix = Matrix4x4.identity
		.Translate(Vector3(-Position.X, -Position.Y, 0))
		.RotateZ(this.Rotation)
		.Scale(Zoom, Zoom, Zoom)
		.Translate(Vector3(Origin.X, Origin.Y, -1));
	}

	public override Matrix4x4 Project(float width, float height) {
		return Matrix4x4.identity.Matrix4x4.Orthographic(0f, width, height, 0f, znear, zfar);
	}
}