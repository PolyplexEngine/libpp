module polyplex.core.input.touch;
import derelict.sdl2.sdl;

public class FingerState {
	/**
		The SDL id for the finger.
	*/
	public SDL_FingerID Id;

	/**
		The origin device the finger was registered on.
	*/
	public int DeviceId;

	/**
		Position in X and Y axis, pressure on Z.
		All values are normalized (between 0 and 1)
	*/
	public Vector3 Position;
}

public class TouchState {
	public FingerState[] Fingers;
}

public class Touch {
	private static int touch_devices = -1;

	/**
		Returns the amount of touch devices connected to the system.
		Calling this will aswell update the internal counter.
	*/
	public static int Count() {
		if (touch_devices != SDL_GetNumTouchDevices()) touch_devices = SDL_GetNumTouchDevices();
		return touch_devices;
	}

	/**
		Returns the state for current touch screen. (-1 for all touch screens.)
	*/
	public static TouchState GetState(int touch_id = -1) {
		// Get the number of touch screens connected to this system.
		if (touch_devices == 0) touch_devices = SDL_GetNumTouchDevices();
		
		TouchState st = new TouchState();
		if (touch_id == -1) {
			foreach(touch_dev; 0 .. touch_devices) {
				int fingers = SDL_GetNumTouchFingers(touch_dev);
				foreach(finger; 0 .. fingers) {
					SDL_Finger f = SDL_GetTouchFinger(touch_dev, finger);
					st.Fingers ~= FingerState(f.id, touch_dev, Vector3(f.x, f.y, f.pressure));
				}
			}
		} else {
			int fingers = SDL_GetNumTouchFingers(touch_id);
			foreach(finger; 0 .. fingers) {
				SDL_Finger f = SDL_GetTouchFinger(touch_dev, finger);
				st.Fingers ~= FingerState(f.id, touch_dev, Vector3(f.x, f.y, f.pressure));
			}
		}
		return st;
	}
}