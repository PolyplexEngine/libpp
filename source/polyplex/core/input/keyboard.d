module polyplex.core.input.keyboard;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv;

enum Keys {
	Unknown,
	A = SDL_SCANCODE_A,
	B = SDL_SCANCODE_B,
	C = SDL_SCANCODE_C,
	D = SDL_SCANCODE_D,
	E = SDL_SCANCODE_E,
	F = SDL_SCANCODE_F,
	G = SDL_SCANCODE_G,
	H = SDL_SCANCODE_H,
	I = SDL_SCANCODE_I,
	J = SDL_SCANCODE_J,
	K = SDL_SCANCODE_K,
	L = SDL_SCANCODE_L,
	M = SDL_SCANCODE_M,
	N = SDL_SCANCODE_N,
	O = SDL_SCANCODE_O,
	P = SDL_SCANCODE_P,
	Q = SDL_SCANCODE_Q,
	R = SDL_SCANCODE_R,
	S = SDL_SCANCODE_S,
	T = SDL_SCANCODE_T,
	U = SDL_SCANCODE_U,
	V = SDL_SCANCODE_V,
	W = SDL_SCANCODE_W,
	X = SDL_SCANCODE_X,
	Y = SDL_SCANCODE_Y,
	Z = SDL_SCANCODE_Z,
	One = SDL_SCANCODE_1,
	Two = SDL_SCANCODE_2,
	Three = SDL_SCANCODE_3,
	Four = SDL_SCANCODE_4,
	Five = SDL_SCANCODE_5,
	Six = SDL_SCANCODE_6,
	Seven = SDL_SCANCODE_7,
	Eight = SDL_SCANCODE_8,
	Nine = SDL_SCANCODE_9,
	Zero = SDL_SCANCODE_0,
	Return = SDL_SCANCODE_RETURN,
	Escape = SDL_SCANCODE_ESCAPE,
	Backspace = SDL_SCANCODE_BACKSPACE,
	Tab = SDL_SCANCODE_TAB,
	Space = SDL_SCANCODE_SPACE,
	Minus = SDL_SCANCODE_MINUS,
	Equals = SDL_SCANCODE_EQUALS,
	LeftBracket = SDL_SCANCODE_LEFTBRACKET,
	RightBracket = SDL_SCANCODE_RIGHTBRACKET,
	Backslash = SDL_SCANCODE_BACKSLASH,
	Nonuhash = SDL_SCANCODE_NONUSHASH,
	Semicolon = SDL_SCANCODE_SEMICOLON,
	Apostrophe = SDL_SCANCODE_APOSTROPHE,
	Grave = SDL_SCANCODE_GRAVE,
	Comma = SDL_SCANCODE_COMMA,
	Period = SDL_SCANCODE_PERIOD,
	Slash = SDL_SCANCODE_SLASH,
	Capslock = SDL_SCANCODE_CAPSLOCK,
	F1 = SDL_SCANCODE_F1,
	F2 = SDL_SCANCODE_F2,
	F3 = SDL_SCANCODE_F3,
	F4 = SDL_SCANCODE_F4,
	F5 = SDL_SCANCODE_F5,
	F6 = SDL_SCANCODE_F6,
	F7 = SDL_SCANCODE_F7,
	F8 = SDL_SCANCODE_F8,
	F9 = SDL_SCANCODE_F9,
	F10 = SDL_SCANCODE_F10,
	F11 = SDL_SCANCODE_F11,
	F12 = SDL_SCANCODE_F12,
	Execute = SDL_SCANCODE_EXECUTE,
	Help = SDL_SCANCODE_HELP,
	Menu = SDL_SCANCODE_MENU,
	Select = SDL_SCANCODE_SELECT,
	Stop = SDL_SCANCODE_STOP,
	Again = SDL_SCANCODE_AGAIN,
	Undo = SDL_SCANCODE_UNDO,
	Cut = SDL_SCANCODE_CUT,
	Copy = SDL_SCANCODE_COPY,
	Paste = SDL_SCANCODE_PASTE,
	Find = SDL_SCANCODE_FIND,
	Mute = SDL_SCANCODE_MUTE,
	VolumeUp = SDL_SCANCODE_VOLUMEUP,
	VolumeDown = SDL_SCANCODE_VOLUMEDOWN,
	KPComma = SDL_SCANCODE_KP_COMMA,
	KPEqual = SDL_SCANCODE_KP_EQUALS,
	International1,
	International2,
	International3,
	International4,
	International5,
	International6,
	International7,
	International8,
	International9,
	Lang1,
	Lang2,
	Lang3,
	Lang4,
	Lang5,
	Lang6,
	Lang7,
	Lang8,
	Lang9,
	AltErase = SDL_SCANCODE_ALTERASE,
	Sysreq = SDL_SCANCODE_SYSREQ,
	Cancel = SDL_SCANCODE_CANCEL,
	Clear = SDL_SCANCODE_CLEAR,
	Prior = SDL_SCANCODE_PRIOR,
	Return2 = SDL_SCANCODE_RETURN2,
	Seperator = SDL_SCANCODE_SEPARATOR,
	Out = SDL_SCANCODE_OUT,
	Oper = SDL_SCANCODE_OPER,
	ClearAgain = SDL_SCANCODE_CLEARAGAIN,
	LeftControl = SDL_SCANCODE_LCTRL,
	LeftShift = SDL_SCANCODE_LSHIFT,
	LeftAlt = SDL_SCANCODE_LALT,
	LeftGUI = SDL_SCANCODE_LGUI,
	RightControl = SDL_SCANCODE_RCTRL,
	RightShift = SDL_SCANCODE_RSHIFT,
	RightAlt = SDL_SCANCODE_RALT,
	RightGUI = SDL_SCANCODE_RGUI,
	Mode,
	AudioNext,
	AudioPrevious,
	AudioStop,
	AudioPlay,
	AudioMute,
	MediaSelect,
	WWW,
	Mail,
	Calculator,
	Computer,
	ACSearch,
	ACHome,
	ACBack,
	ACForward,
	ACStop,
	ACRefresh,
	ACBookmarks,
	BrightnessDown,
	BrightnessUp,
	DisplaySwitch,
	KBDIlluminationToggle,
	KBDIlluminationDown,
	KBDIlluminationUp,
	Eject,
	Sleep,
	App1,
	App2,
	Up = SDL_SCANCODE_UP,
	Down = SDL_SCANCODE_DOWN,
	Left = SDL_SCANCODE_LEFT,
	Right = SDL_SCANCODE_RIGHT,
}

enum KeyState {
	Up,
	Down
}

public class KeyboardState {
	private ubyte[] key_states;

	this(ubyte* key_states, int size) {
		// SDL wants to override the values, so we manually copy them in to another array.
		foreach(i; 0 .. size) {
			this.key_states.length++;
			this.key_states[i] = key_states[i];
		}
	}

	public bool IsKeyDown(Keys key) {
		if (key_states[key] == 1) return true;
		return false;
	}

	public bool IsKeyUp(Keys key) {
		return !IsKeyDown(key);
	}
}

public class Keyboard {
	public static KeyboardState GetState() {
		int elements;
		SDL_PumpEvents();
		ubyte* arr = SDL_GetKeyboardState(&elements);
		return new KeyboardState(arr, elements);
	}
}