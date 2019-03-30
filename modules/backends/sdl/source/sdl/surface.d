module sdl.surface;
import core.surface;
import bindbc.sdl;

class SDLSurface : Surface {
private:
    SDL_Window* window;

public:
    this() {
        super();
    }

    void ModifyBounds(SurfaceBounds preferredBounds) {
        this.bounds = preferredBounds;
        updateSurface();
    }

    @property bool VSync() {
        return true;
    }

    @property void VSync(bool option) {

    }

    @property bool Fullscreen() {
        return false;
    }

    @property void Fullscreen(bool option) {

    }

    bool Visible() {
        return true;
    }

    void Show() {

    }

    void Hide() {

    }

    override T getBackendValue(T)(string name) if (isValidAccessQuery!T) {
        static if (is(T : bool)) {
            if (name == "VSync") return VSync;
            if (name == "Visible") return Visible;
            if (name == "AllowResizing") return false;
        }
        
        return T.init;
    }

    override void setBackendValue(T)(string name, T value) if (isValidAccessQuery!T) {

    }

    void onDestroy() {
        SDL_DestroyWindow(window);
    }
}

shared static this() {
    import core.impl;
    handleSurfaceBoundsChange = (ISurface surface, SurfaceBounds* bounds) {
        SDLSurface sdlSurface = cast(SDLSurface)surface;
        SDL_SetWindowPosition(sdlSurface.window, bounds.X, bounds.Y);
        SDL_SetWindowSize(sdlSurface.window, bounds.Width, bounds.Height);
    };

    handleSurfaceBoundsUpdate = (ISurface surface) {
        SDLSurface sdlSurface = cast(SDLSurface)surface;
        int x, y, w, h;
        SDL_GetWindowPosition(sdlSurface.window, &x, &y);
        SDL_GetWindowSize(sdlSurface.window, &w, &h);
        return SurfaceBounds(x, y, w, h);
    };

    createNewSurface = () {
        return new SDLSurface();
    };
}