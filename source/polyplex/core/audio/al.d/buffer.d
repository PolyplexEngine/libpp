module polyplex.core.audio.al.buffer;
import polyplex.core.audio.al;
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

public struct RawBuffer {
	public ubyte[] Data;
	public int SampleRate;
	public int Length() { return cast(int)Data.length; }
}

/// Circular buffer size (how many ALBuffers to create for streamed audio)
enum CBufferSize = 16;

public class ALBuffer {
	private ALuint[CBufferSize] buff;
	private ALuint[CBufferSize] released;
	private ALint count;
	private AudioRenderFormats f_format;

	/// Audio buffer for streamed audio
	public byte[] PCMOut;

	/// Reference to stream
	private OGGAudioStream stream;

	/// The audio device hosting this buffer.
	public AudioDevice HostDevice;
	public ALuint ALBuff() { return buff[0]; }
	public ALuint[] ALBuffers() { return buff; }

	this(Audio aud, AudioRenderFormats format = AudioRenderFormats.Auto) {
		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, buff.ptr);

		f_format = format;

		// Buffer data from audio source.
		if (format == AudioRenderFormats.Auto) {
			if (aud.Stream.Channels == 1) f_format = AudioRenderFormats.Mono16;
			else if (aud.Stream.Channels == 2) f_format = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels!");
		}

		alBufferData(this.buff[0], f_format, aud.Stream.ReadAll().ptr, cast(int)aud.Stream.Length, cast(int)aud.Stream.SampleRate);
	}

	this(RawBuffer buff, AudioRenderFormats format) {
		if (format == AudioRenderFormats.Auto) throw new Exception("Auto detection not available for RawBuffers.");

		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, this.buff.ptr);
		alBufferData(this.buff[0], format, buff.Data.ptr, buff.Length, buff.SampleRate);
	}

	this(OGGAudioStream stream, AudioRenderFormats format = AudioRenderFormats.Auto, size_t pcmout = 16384) {
		this.stream = stream;

		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, buff.ptr);

		f_format = format;

		// Buffer data from audio source.
		if (format == AudioRenderFormats.Auto) {
			if (stream.Channels == 1) f_format = AudioRenderFormats.Mono16;
			else if (stream.Channels == 2) f_format = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels!");
		}

		// Set length of PCMOut buffer.
		PCMOut.length = pcmout;
		
		// Prestream some.
		foreach(i; 0 .. CBufferSize) {
			long pos = 0;
			while(pos < PCMOut.sizeof) {
				byte[] data = stream.ReadFrame(cast(uint)pcmout);
				PCMOut[pos..pos+data.length] = data;
			}
			alBufferData(released[i], f_format, PCMOut.ptr, cast(int)pos, stream.SampleRate);
		}
	}

	public void Update(ALuint audioSourceId, size_t pcmout = 16384) {
		// Update stream count.
		alGetSourcei(audioSourceId, AL_BUFFERS_PROCESSED, &count);
		alSourceUnqueueBuffers(audioSourceId, count, released.ptr);

		// Stream some.
		foreach(i; 0 .. count) {
			long pos = 0;
			while(pos < PCMOut.sizeof) {
				byte[] data = stream.ReadFrame(cast(uint)pcmout);
				(PCMOut[pos..pos+data.length]) = data;
			}
			alBufferData(released[i], f_format, PCMOut.ptr, cast(int)pos, stream.SampleRate);
		}

		// Queue buffers.
		alSourceQueueBuffers(audioSourceId, count, released.ptr);
	}

	~this() {
		alDeleteBuffers(1, buff.ptr);
	}
}