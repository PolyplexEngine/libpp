module polyplex.core.window;
import polyplex.core.render;
import polyplex.math;
import polyplex;
import events;

public class BoundsEventArgs : EventArgs {
public :
	int X;
	int Y;
	int Width;
	int Height;
}

public class WindowBounds {
private :
	Rectanglei winRect;
	Window owner;
protected :
	void updateWindowBounds(Rectanglei rect) {
		winRect = rect;
	}
public :

	Event!BoundsEventArgs windowResizeRequestEvent;
	Event!BoundsEventArgs windowPositionRequestEvent;
	this(Window owner, Rectanglei winRect) {
		windowResizeRequestEvent = new Event!BoundsEventArgs;
		windowPositionRequestEvent = new Event!BoundsEventArgs;
		this.owner = owner;
		this.winRect = winRect;
	}

	@property int X() {
		return winRect.X;
	}

	@property int Y() {
		return winRect.Y;
	}

	@property int Width() {
		return winRect.Width;
	}

	@property int Height() {
		return winRect.Height;
	}

	@property Vector2i Center() {
		return Vector2i(winRect.Width/2, winRect.Height/2);
	}

	void ResizeWindow(int width, int height) {
		winRect.Width  = width;
		winRect.Height = height;
		BoundsEventArgs args = new BoundsEventArgs();
		args.Width = width;
		args.Height = height;
		windowResizeRequestEvent(cast(void*)this, args);
	}

	void MoveWindow(int x, int y) {
		winRect.X = x;
		winRect.Y = y;
		BoundsEventArgs args = new BoundsEventArgs();
		args.X = x;
		args.Y = y;
		windowPositionRequestEvent(cast(void*)this, args);
	}
}

public abstract class Window {
protected :
	string SurfaceName;
	GraphicsBackend ActiveBackend;
	GraphicsContext ActiveContext;

	void updateBounds(Rectanglei rect) {
		ClientBounds.updateWindowBounds(rect);
	}

	void replaceOn(Game game) {
		game.forceWindowChange(this);
	}

public :
	WindowBounds ClientBounds;
	bool AutoFocus = true;	

	// Base Constructor.
	this(string name) {
		this.SurfaceName = name;
	}

	~this() {
		DestroyContext();
	}

	// Allow Resizing
	abstract @property bool AllowResizing();
	abstract @property void AllowResizing(bool allow);

	// VSync
	abstract @property VSyncState VSync();
	abstract @property void VSync(VSyncState value);

	// Borderless Window Mode
	abstract @property bool Borderless();
	abstract @property void Borderless(bool i);

	// Fullscreen
	abstract @property bool Fullscreen();
	abstract @property void Fullscreen(bool i);

	// Client Bounds
	abstract @property bool Visible();

	// Window Title
	abstract @property string Title();
	abstract @property void Title(string value);

	abstract void Close();
	abstract void Show();
	abstract void UpdateState();
	abstract void SwapBuffers();
	abstract void Focus();
	abstract void SetIcon();

	abstract GraphicsContext CreateContext(GraphicsBackend backend);
	public abstract void DestroyContext();
}

public struct GraphicsContext {
	void* ContextPtr;
}
