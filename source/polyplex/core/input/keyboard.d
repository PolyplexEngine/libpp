module polyplex.core.input.keyboard;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv;

enum KeyCode {
	KeyUnknown,
	KeyA = 4,
	KeyB,
	KeyC,
	KeyD,
	KeyE,
	KeyF,
	KeyG,
	KeyH,
	KeyI,
	KeyJ,
	KeyK,
	KeyL,
	KeyM,
	KeyN,
	KeyO,
	KeyP,
	KeyQ,
	KeyR,
	KeyS,
	KeyT,
	KeyU,
	KeyV,
	KeyW,
	KeyX,
	KeyY,
	KeyZ,
	Key1,
	Key2,
	Key3,
	Key4,
	Key5,
	Key6,
	Key7,
	Key8,
	Key9,
	Key0,
	KeyReturn,
	KeyEscape,
	KeyBackspace,
	KeyTab,
	KeySpace,
	KeyMinus,
	KeyEquals,
	KeyLeftBracket,
	KeyRightBracket,
	KeyBackslash,
	KeyNonuhash,
	KeySemicolon,
	KeyApostrophe,
	KeyGrave,
	KeyComma,
	KeyPeriod,
	KeySlash,
	KeyCapslock,
	KeyF1,
	KeyF2,
	KeyF3,
	KeyF4,
	KeyF5,
	KeyF6,
	KeyF7,
	KeyF8,
	KeyF9,
	KeyF10,
	KeyF11,
	KeyF12,
	KeyExecute,
	KeyHelp,
	KeyMenu,
	KeySelect,
	KeyStop,
	KeyAgain,
	KeyUndo,
	KeyCut,
	KeyCopy,
	KeyPaste,
	KeyFind,
	KeyMute,
	KeyVolumeUp,
	KeyVolumeDown,
	KeyKPComma,
	KeyKPEqual,
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
	KeyAltErase,
	KeySysreq,
	KeyCancel,
	KeyClear,
	KeyPrior,
	KeyReturn2,
	KeySeperator,
	KeyOut,
	KeyOper,
	KeyClearAgain,
	KeyCursorSelect,
	KeyExSelect,
	KeyKP00,
	KeyKP000,
	KeyThousandSeperator,
	KeyDecimalSeperator,
	KeyCurrencyUnit,
	KeyCurrencySubUnit,
	KeyKPLeftParenthesies,
	KeyKPRightParenthesies,
	KeyKPLeftBrace,
	KeyKPRightBrace,
	KeyKPTab,
	KeyKPBackspace,
	KeyKPA,
	KeyKPB,
	KeyKPC,
	KeyKPD,
	KeyKPE,
	KeyKPF,
	KeyKPXOR,
	KeyKPPower,
	KeyKPPercent,
	KeyKPLess,
	KeyKPGreater,
	KeyKPAmpersand,
	KeyKPDBLAmpersand,
	KeyKPVerticalBar,
	KeyKPDBLVerticalBar,
	KeyKPColon,
	KeyKPHash,
	KeyKPSpace,
	KeyKPAT,
	KeyKPExclamation,
	KeyKPMemstore,
	KeyKPMemRecall,
	KeyKPMemAdd,
	KeyKPMemSubtract,
	KeyKPMemMultiply,
	KeyKPMemDivide,
	KeyKPPlusMinus,
	KeyKPClear,
	KeyKPClearEntry,
	KeyKPBinary,
	KeyKPOctal,
	KeyKPDecimal,
	KeyKPHexadecimal,
	KeyLeftControl,
	KeyLeftShift,
	KeyLeftAlt,
	KeyLeftGUI,
	KeyRightControl,
	KeyRightShift,
	KeyRightAlt,
	KeyRightGUI,
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

enum ModKey {
	None 			= 0x0000,
	LeftShift		= 0x0001,
	RightShift		= 0x0002,
	LeftControl		= 0x0040,
	RightControl 	= 0x0080,
	LeftAlt			= 0x0100,
	RightAlt		= 0x0200,
	LeftMeta		= 0x0400,
	RightMeta		= 0x0800,
	Num				= 0x1000,
	Caps			= 0x2000,
	Mode			= 0x4000,
	Reserved		= 0x8000,
	Ctrl			= LeftControl | RightControl,
	Shift			= LeftShift | RightShift,
	Alt				= LeftAlt | RightAlt,
	Meta			= LeftMeta | RightMeta
}

enum KeyState {
	Up,
	Down
}

public class Keyboard {
	public KeyState[KeyCode] kcstates;
	public KeyState[ModKey] mkstates;
	
	this() {
	}

	// Normal Keys
	public bool IsKeyDown(KeyCode kc) {
		return (GetState(kc) == KeyState.Down);
	}

	public bool IsKeyUp(KeyCode kc) {
		return (GetState(kc) == KeyState.Up);
	}

	// Mod Keys.
	public bool IsKeyDown(ModKey mk) {
		return (GetState(mk) == KeyState.Down);
	}

	public bool IsKeyUp(ModKey mk) {
		return (GetState(mk) == KeyState.Up);
	}

	//All Keys

	public KeyState GetState(ModKey mk) { 
		if (mk in mkstates) return mkstates[mk]; 
		return KeyState.Up;
	}

	public KeyState GetState(KeyCode kc) {
		if (kc in kcstates) return kcstates[kc];
		return KeyState.Up;
	}
	
	public string KeyToString(KeyCode kc) {
		const(char)* name = SDL_GetKeyName(cast(SDL_Keycode)kc);
		return to!string(name);
	}


	public void Update(SDL_Event kev) {
		KeyCode k = cast(KeyCode)kev.key.keysym.scancode;
		ModKey m = cast(ModKey)kev.key.keysym.mod;

		if (kev.type == SDL_KEYDOWN) {
			if (k != KeyCode.KeyUnknown) kcstates[k] = KeyState.Down;
			if (m != ModKey.None) mkstates[m] = KeyState.Down;
		} else {
			if (k != KeyCode.KeyUnknown) kcstates[k] = KeyState.Up;
			if (m != ModKey.None) mkstates[m] = KeyState.Up;
		}
	}

	public void Refresh() {
		destroy(kcstates);
		destroy(mkstates);
	}
}