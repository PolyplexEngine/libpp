module polyplex.core.input.mouse;
import derelict.sdl2.sdl;
import polyplex.math;

import std.stdio;

enum MouseButton {

	//Left Mouse Button
	Left = SDL_BUTTON_LEFT,

	//Middle Mouse Button
	Middle = SDL_BUTTON_MIDDLE,

	//Right Mouse Button
	Right = SDL_BUTTON_RIGHT
}

public class MouseState {
	private Vector3 pos;
	private float scroll;
	private int btn_mask;

	this(int x, int y, int btn_mask, float scrolled) {
		this.pos = Vector3(x, y, scrolled);
		this.btn_mask = btn_mask;
	}

	public bool IsButtonPressed(MouseButton button) {
		if (btn_mask & SDL_BUTTON(button)) return true;
		return false;
	}

	public bool IsButtonReleased(MouseButton button) {
		return !IsButtonPressed(button);
	}

	public Vector3 Position() {
		return pos;
	}
}

public class Mouse {
	public static MouseState GetState() {
		int x;
		int y;
		int mask = SDL_GetMouseState(&x, &y);
		float scroll = 0;
		return new MouseState(x, y, mask, scroll);
	}

	public static Vector2 Position() {
		int x;
		int y;
		SDL_GetMouseState(&x, &y);
		return Vector2(x, y);
	}
}