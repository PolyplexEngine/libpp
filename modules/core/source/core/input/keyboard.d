module core.input.keyboard;

enum Keys {
	Unknown,
	A = 0x004,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	One,
	Two,
	Three,
	Four,
	Five,
	Six,
	Seven,
	Eight,
	Nine,
	Zero,
	Return,
	Escape,
	Backspace,
	Tab,
	Space,
	Minus,
	Equals,
	LeftBracket,
	RightBracket,
	Backslash,
	Nonuhash,
	Semicolon,
	Apostrophe,
	Grave,
	Comma,
	Period,
	Slash,
	Capslock,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	Execute,
	Help,
	Menu,
	Select,
	Stop,
	Again,
	Undo,
	Cut,
	Copy,
	Paste,
	Find,
	Mute,
	VolumeUp,
	VolumeDown,
	KPComma,
	KPEqual,
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
	AltErase,
	Sysreq,
	Cancel,
	Clear,
	Prior,
	Return2,
	Seperator,
	Out,
	Oper,
	ClearAgain,
	LeftControl,
	LeftShift,
	LeftAlt,
	LeftGUI,
	RightControl,
	RightShift,
	RightAlt,
	RightGUI,
	Mode = 0x101,
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
	Up,
	Down,
	Left,
	Right
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

	/**
		Returns true if the specified key is down (pressed).
	*/
	public bool IsKeyDown(Keys key) {
		if (key_states[key] == 1) return true;
		return false;
	}

	/**
		Returns true if all of the specified keys are down (pressed).
	*/
	public bool AreKeysDown(Keys[] kees) {
		foreach(Keys k; kees) {
			if (IsKeyUp(k)) return false;
		}
		return true;
	}

	/**
		Returns true if the specified key is up (not pressed).
	*/
	public bool IsKeyUp(Keys key) {
		return !IsKeyDown(key);
	}

	/**
		Returns true if all of the specified keys are up (not pressed).
	*/
	public bool AreKeysUp(Keys[] kees) {
		foreach(Keys k; kees) {
			if (IsKeyDown(k)) return false;
		}
		return true;
	}
}

public class Keyboard {

	/**
		Returns the current state of the keyboard.
	*/
	/*public static KeyboardState GetState() {
		int elements;
		ubyte* arr = SDL_GetKeyboardState(&elements);
		return new KeyboardState(arr, elements);
	}*/
}