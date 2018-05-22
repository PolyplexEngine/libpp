module polyplex.core.audio.buffer;
import polyplex.core.audio;
import ppc.audio;
import derelict.openal;

import std.stdio;

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
		if (aud.Channels == 1) alBufferData(this.buff, AL_FORMAT_MONO16, aud.Samples.ptr, cast(int)aud.Length, cast(int)aud.SampleRate);
		else if (aud.Channels == 2) alBufferData(this.buff, AL_FORMAT_STEREO16, aud.Samples.ptr, cast(int)aud.Length, cast(int)aud.SampleRate);
		else throw new Exception("Unsupported amount of channels!");
	}
	~this() {
		alDeleteBuffers(1, &this.buff);
	}
}