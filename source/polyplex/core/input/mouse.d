module polyplex.core.input.mouse;
import derelict.sdl2.sdl;
import polyplex.math;

enum MouseButton {

	//Left Mouse Button
	Left = SDL_BUTTON_LEFT,

	//Middle Mouse Button
	Middle = SDL_BUTTON_MIDDLE,

	//Right Mouse Button
	Right = SDL_BUTTON_RIGHT
}

public class MouseState {
	private Vector2 pos;
	private int btn_mask;

	this(int x, int y, int btn_mask) {
		this.pos = Vector2(x, y);
		this.btn_mask = btn_mask;
	}

	public bool IsButtonPressed(MouseButton button) {
		if (btn_mask & SDL_BUTTON(button)) return true;
		return false;
	}

	public bool IsButtonReleased(MouseButton button) {
		return !IsButtonPressed(button);
	}
}

public class Mouse {
	public static MouseState GetState() {
		SDL_PumpEvents();
		int x;
		int y;
		int mask = SDL_GetMouseState(&x, &y);
		return new MouseState(x, y, mask);
	}

	public static Vector2 Position() {
		SDL_PumpEvents();
		int x;
		int y;
		SDL_GetMouseState(&x, &y);
		return Vector2(x, y);
	}
}