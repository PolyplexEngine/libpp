module polyplex.core.rendersurface;
import polyplex.core.render;
import polyplex.math;
import polyplex;

public class RenderSurface {
	protected string SurfaceName;
	protected GraphicsBackend ActiveBackend;
	protected GraphicsContext ActiveContext;
	public bool AutoFocus = true;

	// Base Constructor.
	public this(string name) {
		this.SurfaceName = name;
	}

	// VSync
	public abstract @property VSyncState VSync();
	public abstract @property void VSync(VSyncState value);

	// Client Bounds
	public abstract @property Rectangle ClientBounds();
	public abstract @property bool Visible();

	public abstract @property string Title();
	public abstract @property void Title(string value);

	public abstract void Close();
	public abstract void Show();
	public abstract void UpdateState();
	public abstract void SwapBuffers();

	public abstract GraphicsContext CreateContext(GraphicsBackend backend);
	public abstract void DestroyContext();
}

public struct GraphicsContext {
	void* ContextPtr;
}
