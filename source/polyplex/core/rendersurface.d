module polyplex.core.rendersurface;
import polyplex.core.render;
import polyplex.math;
static import polyplex;

public class RenderSurface {
	public bool AutoFocus = true;

	// Base Constructor.
	public this(string name);

	// Backend
	public @property polyplex.GraphicsBackend GLBackend() { return polyplex.ChosenBackend; }

	// VSync
	public @property VSyncState VSync() {
		return Renderer.VSync;
	}
	public @property void VSync(VSyncState value) { Renderer.VSync = value; }

	// Client Bounds
	public abstract @property Rectangle ClientBounds();
	public abstract @property bool Visible();

	public abstract @property string Title();
	public abstract @property void Title(string value);

	public abstract void Close();
	public abstract void Show();
	public abstract void UpdateState();
}
