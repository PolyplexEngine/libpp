module polyplex.core.input;
public import polyplex.core.input.keyboard;
public import polyplex.core.input.mouse;
public import polyplex.core.input.controller;
public import polyplex.core.input.touch;
import derelict.sdl2.sdl;
import std.stdio;

enum InputType {
	Controller,
	Touch,
	Keyboard,
	Mouse
}

class InputHandler {
	private Controller controller;
	private Keyboard keyboard;
	private Mouse mouse;
	private Touch touch;

	this() {
		controller = new Controller();
		keyboard = new Keyboard();
		mouse = new Mouse();
		touch = new Touch();
	}

	public bool IsKeyDown(KeyCode kc) { return keyboard.IsKeyDown(kc);}
	public bool IsKeyDown(ModKey mk) { return keyboard.IsKeyDown(mk); }
	public bool IsKeyUp(KeyCode kc) { return keyboard.IsKeyUp(kc); }
	public bool IsKeyUp(ModKey mk) { return keyboard.IsKeyUp(mk); }

	public KeyState GetState(KeyCode kc) { return keyboard.GetState(kc); }
	public KeyState GetState(ModKey mk) { return keyboard.GetState(mk); }

	public void Update(SDL_Event ev) {
		if (ev.type == SDL_KEYUP || ev.type == SDL_KEYDOWN) {
			keyboard.Update(ev);
		}
		mouse.Update();
		touch.Update();
		controller.Update();
	}

	public void Refresh() {
		keyboard.Refresh();
		mouse.Refresh();
		touch.Refresh();
		controller.Refresh();
	}
}

