module polyplex.core.audio.listener;
import derelict.openal;
import polyplex.math;

public class Listener {
	private static Vector3 position;
	private static Vector3 velocity;

	public static @property Vector3 Position() {
		return position;
	}
	public static @property void Position(Vector3 val) {
		this.position = val;
		alListenerfv(AL_POSITION, val.data.ptr);
	}

	public static @property Vector3 Velocity() {
		return velocity;
	}
	public static @property void Velocity(Vector3 val) {
		this.velocity = val;
		alListenerfv(AL_VELOCITY, val.data.ptr);
	}
}