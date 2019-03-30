module core.surface;
import core.common;
import core.impl;
import polyplex.math;

struct SurfaceBounds {
public:
    int X;
    int Y;
    int Width;
    int Height;

    Vector2i Center() {
        return Vector2i(Width/2, Height/2);
    }
}

interface ISurface : IDisposable {
protected:
    void updateSurface();

    void onSurfaceResize();

public:
    /// Returns the bounds (position and size) of the surface, in relation to its parent.
    /// The parent is backend dependent, as a GTK+ Widget, it's its containing widget
    /// As an SDL window, it's the screen.
    ref SurfaceBounds ClientBounds();

    /// Instructs the surface to *try* to resize its bounds
    /// The surface _may_ or may **not** do this, you can test the capability via the capabilities managment
    void ModifyBounds(SurfaceBounds preferredBounds);

    /// Gets the surface vsync option
    /// Some backends might support more vsync options, to see those you can query the backend directly.
    @property bool VSync();

    /// Sets the surface vsync option
    /// Some backends might support more vsync options, to see those you can query the backend directly.
    @property void VSync(bool option);

    /// Gets the surface fullscreen option, It might or might **not** do anything.
    /// On Gtk+ it'll always return false
    /// On SDL2 it'll return wether the SDL2 window is fullscreen
    @property bool Fullscreen();

    /// Sets the surface fullscreen option, It might or might **not** do anything.
    /// On Gtk+ it'll do absolutely nothing
    /// On SDL2 it'll make the window full screen (if possible)
    @property void Fullscreen(bool option);

    /// Gets wether the surface is hidden or shown
    bool Visible();

    /// Show the surface, what "show" means is backend dependent
    /// On Gtk+ it means showing the widget
    /// On SDL2 it means showing the window.
    void Show();

    /// Hide the surface, what "hide" means is backend dependent
    /// On Gtk+ it means hiding the widget
    /// On SDL2 it means hiding the window.
    void Hide();

    /// Called on backend destruction
    /// You are not supposed to call this your self, unless you are writing your own backend
    /// Or if you are doing weird surface shenannigans
    void onDestroy();

    /// Index extra options (string)
    string opIndex(string name);

    /// Index extra options (int)
    int opIndex(string name);

    /// Index extra options (float)
    float opIndex(string name);
    
    /// Index extra options (bool)
    bool opIndex(string name);

    /// Index extra options (string)
    string opIndexAssign(string val, string name);

    /// Index extra options (int)
    int opIndexAssign(int val, string name);

    /// Index extra options (float)
    float opIndexAssign(float val, string name);
    
    /// Index extra options (bool)
    bool opIndexAssign(bool val, string name);
}

/// A surface, extend this for basic handling of some common Surface tasks
/// Otherwise, use ISurface.
abstract class Surface : ISurface {
protected:
    /// The bounds of the window, should be updated regularly
    SurfaceBounds bounds;

    /// Run when the bounds has been updated
    void updateSurface() {
        handleSurfaceBoundsChange(this, &bounds);
    }
    
    /// Run when the surface has been resized.
    void onSurfaceResize() {
        bounds = handleSurfaceBoundsUpdate(this);
    }

    enum isValidAccessQuery(T) = is(T : string) || is (T : int) || is (T : float) || is(T : bool);
    T getBackendValue(T)(string name) if (isValidAccessQuery!T);
    void setBackendValue(T)(string name, T value) if (isValidAccessQuery!T);

public:
    ref SurfaceBounds ClientBounds() {
        return bounds;
    }

    this() {
        bounds = handleSurfaceBoundsUpdate(this);
    }

    ~this() {
        onDestroy();
    }


    /// Index extra options (string)
    string opIndex(string name) {
        return getBackendValue!string(name);
    }

    /// Index extra options (int)
    int opIndex(string name) {
        return getBackendValue!int(name);
    }

    /// Index extra options (float)
    float opIndex(string name) {
        return getBackendValue!float(name);
    }
    
    /// Index extra options (bool)
    bool opIndex(string name) {
        return getBackendValue!bool(name);
    }

    /// Index extra options (string)
    string opIndexAssign(string val, string name) {
        setBackendValue!string(name, val);
        return val;
    }

    /// Index extra options (int)
    int opIndexAssign(int val, string name) {
        setBackendValue!int(name, val);
        return val;
    }

    /// Index extra options (float)
    float opIndexAssign(float val, string name) {
        setBackendValue!float(name, val);
        return val;
    }
    
    /// Index extra options (bool)
    bool opIndexAssign(bool val, string name) {
        setBackendValue!bool(name, val);
        return val;
    }
}
