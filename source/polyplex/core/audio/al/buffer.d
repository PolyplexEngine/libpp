module polyplex.core.audio.al.buffer;
import polyplex.core.audio.al;
import polyplex.core.audio;
import ppc.types.audio;
import derelict.openal;

import std.stdio;


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
	private Audio stream;

	/// The audio device hosting this buffer.
	public AudioDevice HostDevice;
	public ALuint ALBuff() { return buff[0]; }
	public ALuint[] ALBuffers() { return buff; }

	this(Audio aud, AudioRenderFormats format = AudioRenderFormats.Auto) {
		//Clear any present errors.
		alGetError();

		this.stream = aud;
		
		// Generate buffer.
		alGenBuffers(1, buff.ptr);

		f_format = format;

		// Buffer data from audio source.
		if (format == AudioRenderFormats.Auto) {
			import std.conv;
			if (aud.info.channels == 1) f_format = AudioRenderFormats.Mono16;
			else if (aud.info.channels == 2) f_format = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels! " ~ aud.info.channels.to!string);
		}

		alBufferData(this.buff[0], f_format, aud.readAll.ptr, cast(int)aud.info.pcmLength, cast(int)aud.info.bitrate);
	}

	this(RawBuffer buff, AudioRenderFormats format) {
		if (format == AudioRenderFormats.Auto) throw new Exception("Auto detection not available for RawBuffers.");

		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, this.buff.ptr);
		alBufferData(this.buff[0], format, buff.Data.ptr, buff.Length, buff.SampleRate);
	}

	this(Audio stream, AudioRenderFormats format = AudioRenderFormats.Auto, size_t pcmout = 16384) {
		this.stream = stream;

		//Clear any present errors.
		alGetError();
		
		// Generate buffer.
		alGenBuffers(1, buff.ptr);

		f_format = format;

		// Buffer data from audio source.
		if (format == AudioRenderFormats.Auto) {
			if (stream.info.channels == 1) f_format = AudioRenderFormats.Mono16;
			else if (stream.info.channels == 2) f_format = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels!");
		}

		// Set length of PCMOut buffer.
		PCMOut.length = pcmout;
		
		// Prestream some.
		foreach(i; 0 .. CBufferSize) {
			long pos = 0;
			while(pos < PCMOut.sizeof) {
				byte[] data;
				stream.read(data.ptr, pcmout);
				PCMOut[pos..pos+data.length] = data;
			}
			alBufferData(released[i], f_format, PCMOut.ptr, cast(int)pos, cast(int)stream.info.bitrate);
		}
	}

	public void FirstUpdate(ALuint audioSourceId) {
		// Queue buffers.
		alSourceQueueBuffers(audioSourceId, count, buff.ptr);
	}

	public void Update(ALuint audioSourceId, size_t pcmout = 16384) {
		// Update stream count.
		alGetSourcei(audioSourceId, AL_BUFFERS_PROCESSED, &count);
		alSourceUnqueueBuffers(audioSourceId, count, released.ptr);

		// Stream some.
		foreach(i; 0 .. count) {
			long pos = 0;
			while(pos < PCMOut.sizeof) {
				byte[] data;
				stream.read(data.ptr, pcmout);
				(PCMOut[pos..pos+data.length]) = data;
			}
			alBufferData(released[i], f_format, PCMOut.ptr, cast(int)pos, cast(int)stream.info.bitrate);
		}

		// Queue buffers.
		alSourceQueueBuffers(audioSourceId, count, released.ptr);
	}

	public void Rewind() {

	}

	~this() {
		alDeleteBuffers(1, buff.ptr);
	}
}