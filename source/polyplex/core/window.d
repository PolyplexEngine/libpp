module polyplex.core.window;
import polyplex.core.render;
import polyplex.math;
import polyplex;

public class Window {
	protected string SurfaceName;
	protected GraphicsBackend ActiveBackend;
	protected GraphicsContext ActiveContext;
	public bool AutoFocus = true;

	// Base Constructor.
	public this(string name) {
		this.SurfaceName = name;
	}

	public ~this() {
		DestroyContext();
	}

	// Allow Resizing
	public abstract @property bool AllowResizing();
	public abstract @property void AllowResizing(bool allow);

	// VSync
	public abstract @property VSyncState VSync();
	public abstract @property void VSync(VSyncState value);

	// Borderless Window Mode
	public abstract @property bool Borderless();
	public abstract @property void Borderless(bool i);

	// Fullscreen
	public abstract @property bool Fullscreen();
	public abstract @property void Fullscreen(bool i);

	// Client Bounds
	public abstract @property Rectangle ClientBounds();
	public abstract @property bool Visible();

	// Window Title
	public abstract @property string Title();
	public abstract @property void Title(string value);

	public abstract void Close();
	public abstract void Show();
	public abstract void UpdateState();
	public abstract void SwapBuffers();
	public abstract void Focus();
	public abstract void SetIcon();

	public abstract GraphicsContext CreateContext(GraphicsBackend backend);
	public abstract void DestroyContext();
}

public struct GraphicsContext {
	void* ContextPtr;
}
