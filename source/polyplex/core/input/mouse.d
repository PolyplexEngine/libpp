module polyplex.core.input.mouse;
import derelict.sdl2.sdl;

enum MouseButton {
	//No buttons.
	Idle = 0,

	//Left Mouse Button
	Left = 1,

	//Middle Mouse Button
	Middle = 2,

	//Right Mouse Button
	Right = 3
}

public class Mouse {
	private int x;
	private int y;
	private MouseButton Pressed;

	public void Update() {

	}

	public void Refresh() {
		
	}
}