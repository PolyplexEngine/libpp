module polyplex.core.input.inputdev;
import derelict.sdl2.sdl;

/**
	Contains static functions for backend use.
	You won't in normal circumstances need to use this.
*/
public class InputDevice {
	/**
		Calls SDL_PumpEvents to update events for input.
		You wouldn't normally run this, unless you are not using the libpp Game implementation.
		If you aren't, only call this once per frame.
	*/
	public static void UpdateSDLEvents() {
		SDL_PumpEvents();
	}
}