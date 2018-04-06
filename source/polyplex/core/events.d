module polyplex.core.events;
import polyplex.core.input;
import derelict.sdl2.sdl;
import std.stdio;
import sev.event;

public class GameResizeEventArgs : EventArgs {
	public void* SDLEvent;
}

public class GameEventSystem {
	private bool lastHandled;
	private SDL_Event ev;

	public Event OnWindowSizeChanged = new Event();
	public Event OnExitRequested = new Event();

	this() {
	}

	public void Update() {
		while (SDL_PollEvent(&ev)) {
			lastHandled = true;
			if (ev.type == SDL_QUIT) {
				OnExitRequested(cast(void*)this);
			}
			
			if (ev.type == SDL_WINDOWEVENT) {
				if (ev.window.event == SDL_WINDOWEVENT_SIZE_CHANGED || ev.window.event == SDL_WINDOWEVENT_RESIZED) {
					GameResizeEventArgs args = new GameResizeEventArgs();
					args.SDLEvent = cast(void*)ev.window.event;
					OnWindowSizeChanged(cast(void*)this, args);
				}
			}

			//Update last handled.
			lastHandled = false;
		}
	}
}