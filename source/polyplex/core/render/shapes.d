module polyplex.core.render.shapes;
import polyplex.math;
import std.stdio;

public abstract class Shape {
	public abstract float[][] GetVertices();
}

class Square : Shape {
	private float[][] verts;
	public @property float[][] Vertices() { return verts; }
	
	this(Rectangle rect) {
		Vector2[] vecs = new Vector2[4];
		vecs[0] = Vector2(rect.X, rect.Height);
		vecs[1] = Vector2(rect.X, rect.Y);
		vecs[2] = Vector2(rect.Width, rect.Y);
		vecs[3] = Vector2(rect.Width, rect.Height);
		Polygon pg = new Polygon(vecs);
		writeln(this.verts);
		this.verts = pg.Vertices;
	}

	public override float[][] GetVertices() {
		return this.verts;
	}
}

class FSquare : Shape {
	private float[][] verts;
	public @property float[][] Vertices() { return verts; }
	
	this(Vector4 rect) {
		Vector2[] vecs = new Vector2[4];
		vecs[0] = Vector2(rect.X, rect.W);
		vecs[1] = Vector2(rect.X, rect.Y);
		vecs[2] = Vector2(rect.Z, rect.W);
		vecs[3] = Vector2(rect.Z, rect.Y);
		Polygon pg = new Polygon(vecs);
		this.verts = pg.Vertices;
	}

	public override float[][] GetVertices() {
		return this.verts;
	}
}

class Polygon : Shape {
	private float[][] verts;
	public @property float[][] Vertices() { return verts; }
	this(Vector2[] points) {
		verts.length = points.length;
		for (int i = 0; i < points.length; i++) {
			verts[i].length = 2;
			verts[i][0] = points[i].X;
			verts[i][1] = points[i].Y;
		}
	}

	public override float[][] GetVertices() {
		return Vertices;
	}
}