module polyplex.core.input.mouse;
import polyplex.core.events;
import bindbc.sdl;
import polyplex.math;

import std.stdio;

enum MouseButton : ubyte {

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

	ubyte SDLButton(ubyte x) {
		return cast(ubyte)(1 << (x-1));
	}

	/**
		Returns true if the specified MouseButton is pressed.
	*/
	public bool IsButtonPressed(MouseButton button) {
		if (btn_mask & SDLButton(button)) return true;
		return false;
	}

	/**
		Returns true if the specified MouseButton is released (not pressed).
	*/
	public bool IsButtonReleased(MouseButton button) {
		return !IsButtonPressed(button);
	}

	/**
		Returns the position and scroll for the mouse.
		Z = Scrollwheel
	*/
	public Vector3 Position() {
		return pos;
	}
}

public class Mouse {

	private static int lastX = 0;
	private static int lastY = 0;

	/**
		Returns the current state of the mouse.
	*/
	public static MouseState GetState() {
		
		// Cursed allocation
		int* x = new int;
		int* y = new int;
		immutable(int) mask = SDL_GetMouseState(x, y);

		// Get last state if we're null
		if (x is null) x = &lastX;
		if (y is null) y = &lastY;

		// Update last state to newest state
		lastX = *x;
		lastY = *y;

		float scroll = 0;
		foreach(SDL_Event ev; PPEvents.Events) {
			if (ev.type == SDL_MOUSEWHEEL) {
				scroll = ev.wheel.y;
			}
		}
		return new MouseState(*x, *y, mask, scroll);
	}

	/**
		Gets the current state of the mouse.
	*/
	public static Vector2 Position() {
		
		// Cursed allocation
		int* x = new int;
		int* y = new int;
		SDL_GetMouseState(x, y);

		// Get last state if we're null
		if (x is null) x = &lastX;
		if (y is null) y = &lastY;

		// Update last state to newest state
		lastX = *x;
		lastY = *y;

		return Vector2(*x, *y);
	}
}