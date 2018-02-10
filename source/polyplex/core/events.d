module polyplex.core.events;
import polyplex.core.input;
import derelict.sdl2.sdl;
import polyplex.events;
import std.stdio;

public class GameEventSystem {
	private InputHandler input;
	private bool lastHandled;
	private SDL_Event ev;

	public @property InputHandler Input() { return input; }

	public Event OnWindowSizeChanged = new BasicEvent();
	public Event OnExitRequested = new BasicEvent();

	this(InputHandler handler) {
		this.input = handler;
	}

	public void Update() {
		while (SDL_PollEvent(&ev)) {
			lastHandled = true;
			if (ev.type == SDL_QUIT) {
				OnExitRequested(cast(void*)this);
			}
			
			if (ev.type == SDL_WINDOWEVENT) {
				if (ev.window.event == SDL_WINDOWEVENT_SIZE_CHANGED || ev.window.event == SDL_WINDOWEVENT_RESIZED) {
					OnWindowSizeChanged(cast(void*)this, cast(void*)ev.window.event);
				}
			}

			input.Update(ev);

			//Update last handled.
			lastHandled = false;
		}
	}
}