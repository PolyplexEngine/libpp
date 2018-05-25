module polyplex.core.audio.buffer;
import polyplex.core.audio;
import ppc.audio;
import derelict.openal;

import std.stdio;

public enum AudioRenderFormats : int {
	/**
		Auto detect (only available for PPC Audio streams)
	*/
	Auto = 0,
	Mono8 = AL_FORMAT_MONO8,
	Mono16 = AL_FORMAT_MONO16,
	MonoFloat = AL_FORMAT_MONO_FLOAT32,

	Stereo8 = AL_FORMAT_STEREO8,
	Stereo16 = AL_FORMAT_STEREO16,
	StereoFloat = AL_FORMAT_STEREO_FLOAT32,
}

public class RawBuffer {
	public ubyte[] Data;
	public int SampleRate;
	public int Length() { return cast(int)Data.length; }
	
}

public class ALBuffer {
	private ALuint buff;

	/// The audio device hosting this buffer.
	public AudioDevice HostDevice;
	public ALuint ALBuff() { return buff; }

	this(Audio aud, AudioRenderFormats format = AudioRenderFormats.Auto) {
		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, &buff);

		AudioRenderFormats f_format = format;

		// Buffer data from audio source.
		if (format == AudioRenderFormats.Auto) {
			if (aud.Channels == 1) f_format = AudioRenderFormats.Mono16;
			else if (aud.Channels == 2) f_format = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels!");
		}

		alBufferData(this.buff, f_format, aud.Samples.ptr, cast(int)aud.Length, cast(int)aud.SampleRate);
	}

	this(RawBuffer buff, AudioRenderFormats format) {
		if (format == AudioRenderFormats.Auto) throw new Exception("Auto detection not available for RawBuffers.");

		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, &this.buff);
		alBufferData(this.buff, format, buff.Data.ptr, buff.Length, buff.SampleRate);
	}

	~this() {
		alDeleteBuffers(1, &this.buff);
	}
}