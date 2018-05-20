module polyplex.core.audio.buffer;
import polyplex.core.audio;
import ppc.audio;
import derelict.openal;

public class ALBuffer {
	private ALuint buff;

	/// The audio device hosting this buffer.
	public AudioDevice HostDevice;
	public ALuint ALBuff() { return buff; }

	this(Audio aud) {
		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, &buff);

		// Buffer data from audio source.
		if (aud.Channels == 1) alBufferData(this.buff, AL_FORMAT_MONO8, aud.Samples.ptr, cast(int)aud.Length, cast(int)aud.SampleRate);
		else alBufferData(this.buff, AL_FORMAT_STEREO8, aud.Samples.ptr, cast(int)aud.Length, cast(int)aud.SampleRate);
	}
	~this() {
		alDeleteBuffers(1, &this.buff);
	}
}