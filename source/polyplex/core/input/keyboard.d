module polyplex.core.input.keyboard;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv;

enum Keys {
	KeyUnknown,
	KeyA = SDL_SCANCODE_A,
	KeyB = SDL_SCANCODE_B,
	KeyC = SDL_SCANCODE_C,
	KeyD = SDL_SCANCODE_D,
	KeyE = SDL_SCANCODE_E,
	KeyF = SDL_SCANCODE_F,
	KeyG = SDL_SCANCODE_G,
	KeyH = SDL_SCANCODE_H,
	KeyI = SDL_SCANCODE_I,
	KeyJ = SDL_SCANCODE_J,
	KeyK = SDL_SCANCODE_K,
	KeyL = SDL_SCANCODE_L,
	KeyM = SDL_SCANCODE_M,
	KeyN = SDL_SCANCODE_N,
	KeyO = SDL_SCANCODE_O,
	KeyP = SDL_SCANCODE_P,
	KeyQ = SDL_SCANCODE_Q,
	KeyR = SDL_SCANCODE_R,
	KeyS = SDL_SCANCODE_S,
	KeyT = SDL_SCANCODE_T,
	KeyU = SDL_SCANCODE_U,
	KeyV = SDL_SCANCODE_V,
	KeyW = SDL_SCANCODE_W,
	KeyX = SDL_SCANCODE_X,
	KeyY = SDL_SCANCODE_Y,
	KeyZ = SDL_SCANCODE_Z,
	Key1 = SDL_SCANCODE_1,
	Key2 = SDL_SCANCODE_2,
	Key3 = SDL_SCANCODE_3,
	Key4 = SDL_SCANCODE_4,
	Key5 = SDL_SCANCODE_5,
	Key6 = SDL_SCANCODE_6,
	Key7 = SDL_SCANCODE_7,
	Key8 = SDL_SCANCODE_8,
	Key9 = SDL_SCANCODE_9,
	Key0 = SDL_SCANCODE_0,
	KeyReturn = SDL_SCANCODE_RETURN,
	KeyEscape = SDL_SCANCODE_ESCAPE,
	KeyBackspace = SDL_SCANCODE_BACKSPACE,
	KeyTab = SDL_SCANCODE_TAB,
	KeySpace = SDL_SCANCODE_SPACE,
	KeyMinus = SDL_SCANCODE_MINUS,
	KeyEquals = SDL_SCANCODE_EQUALS,
	KeyLeftBracket = SDL_SCANCODE_LEFTBRACKET,
	KeyRightBracket = SDL_SCANCODE_RIGHTBRACKET,
	KeyBackslash = SDL_SCANCODE_BACKSLASH,
	KeyNonuhash = SDL_SCANCODE_NONUSHASH,
	KeySemicolon = SDL_SCANCODE_SEMICOLON,
	KeyApostrophe = SDL_SCANCODE_APOSTROPHE,
	KeyGrave = SDL_SCANCODE_GRAVE,
	KeyComma = SDL_SCANCODE_COMMA,
	KeyPeriod = SDL_SCANCODE_PERIOD,
	KeySlash = SDL_SCANCODE_SLASH,
	KeyCapslock = SDL_SCANCODE_CAPSLOCK,
	KeyF1 = SDL_SCANCODE_F1,
	KeyF2 = SDL_SCANCODE_F2,
	KeyF3 = SDL_SCANCODE_F3,
	KeyF4 = SDL_SCANCODE_F4,
	KeyF5 = SDL_SCANCODE_F5,
	KeyF6 = SDL_SCANCODE_F6,
	KeyF7 = SDL_SCANCODE_F7,
	KeyF8 = SDL_SCANCODE_F8,
	KeyF9 = SDL_SCANCODE_F9,
	KeyF10 = SDL_SCANCODE_F10,
	KeyF11 = SDL_SCANCODE_F11,
	KeyF12 = SDL_SCANCODE_F12,
	KeyExecute = SDL_SCANCODE_EXECUTE,
	KeyHelp = SDL_SCANCODE_HELP,
	KeyMenu = SDL_SCANCODE_MENU,
	KeySelect = SDL_SCANCODE_SELECT,
	KeyStop = SDL_SCANCODE_STOP,
	KeyAgain = SDL_SCANCODE_AGAIN,
	KeyUndo = SDL_SCANCODE_UNDO,
	KeyCut = SDL_SCANCODE_CUT,
	KeyCopy = SDL_SCANCODE_COPY,
	KeyPaste = SDL_SCANCODE_PASTE,
	KeyFind = SDL_SCANCODE_FIND,
	KeyMute = SDL_SCANCODE_MUTE,
	KeyVolumeUp = SDL_SCANCODE_VOLUMEUP,
	KeyVolumeDown = SDL_SCANCODE_VOLUMEDOWN,
	KeyKPComma = SDL_SCANCODE_KP_COMMA,
	KeyKPEqual = SDL_SCANCODE_KP_EQUALS,
	KeyInternational1,
	KeyInternational2,
	KeyInternational3,
	KeyInternational4,
	KeyInternational5,
	KeyInternational6,
	KeyInternational7,
	KeyInternational8,
	KeyInternational9,
	KeyLang1,
	KeyLang2,
	KeyLang3,
	KeyLang4,
	KeyLang5,
	KeyLang6,
	KeyLang7,
	KeyLang8,
	KeyLang9,
	KeyAltErase = SDL_SCANCODE_ALTERASE,
	KeySysreq = SDL_SCANCODE_SYSREQ,
	KeyCancel = SDL_SCANCODE_CANCEL,
	KeyClear = SDL_SCANCODE_CLEAR,
	KeyPrior = SDL_SCANCODE_PRIOR,
	KeyReturn2 = SDL_SCANCODE_RETURN2,
	KeySeperator = SDL_SCANCODE_SEPARATOR,
	KeyOut = SDL_SCANCODE_OUT,
	KeyOper = SDL_SCANCODE_OPER,
	KeyClearAgain = SDL_SCANCODE_CLEARAGAIN,
	KeyLeftControl = SDL_SCANCODE_LCTRL,
	KeyLeftShift = SDL_SCANCODE_LSHIFT,
	KeyLeftAlt = SDL_SCANCODE_LALT,
	KeyLeftGUI = SDL_SCANCODE_LGUI,
	KeyRightControl = SDL_SCANCODE_RCTRL,
	KeyRightShift = SDL_SCANCODE_RSHIFT,
	KeyRightAlt = SDL_SCANCODE_RALT,
	KeyRightGUI = SDL_SCANCODE_RGUI,
	KeyMode,
	KeyAudioNext,
	KeyAudioPrevious,
	KeyAudioStop,
	KeyAudioPlay,
	KeyAudioMute,
	KeyMediaSelect,
	KeyWWW,
	KeyMail,
	KeyCalculator,
	KeyComputer,
	KeyACSearch,
	KeyACHome,
	KeyACBack,
	KeyACForward,
	KeyACStop,
	KeyACRefresh,
	KeyACBookmarks,
	KeyBrightnessDown,
	KeyBrightnessUp,
	KeyDisplaySwitch,
	KeyKBDIlluminationToggle,
	KeyKBDIlluminationDown,
	KeyKBDIlluminationUp,
	KeyEject,
	KeySleep,
	KeyApp1,
	KeyApp2,

	KeyUp = SDL_SCANCODE_UP,
	KeyDown = SDL_SCANCODE_DOWN,
	KeyLeft = SDL_SCANCODE_LEFT,
	KeyRight = SDL_SCANCODE_RIGHT,
}

enum KeyState {
	Up,
	Down
}

public class KeyboardState {
	private ubyte* key_states;
	private int key_state_len;

	this(ubyte* key_states, int size) {
		this.key_states = key_states;
		this.key_state_len = size;
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