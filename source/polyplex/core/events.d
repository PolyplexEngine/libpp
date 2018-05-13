module polyplex.core.events;
import polyplex.core.input;
import derelict.sdl2.sdl;
import std.stdio;
import sev.event;

public class GameResizeEventArgs : EventArgs {
	public void* SDLEvent;
}

public class PPEvents {
	public static SDL_Event[] Events;

	public static PumpEvents() {
		// Then poll everything and push it to our own event queue
		Events.length = 0;
		SDL_Event ev;
		while(SDL_PollEvent(&ev)) {
			Events ~= ev;
		}
	}
}

public class GameEventSystem {
	private bool lastHandled;

	public Event OnWindowSizeChanged = new Event();
	public Event OnExitRequested = new Event();

	this() {
	}

	public void Update() {

		foreach(SDL_Event ev; PPEvents.Events) {
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