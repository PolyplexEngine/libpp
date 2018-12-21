module polyplex.core.audio.soundeffect;
import polyplex.core.audio;
import ppc.types.audio;
import openal;
import ppc.backend.cfile;
import polyplex.math;

/// A sound effect which is persistent in memory.
public class SoundEffect {
private:
    // Buffer
    Audio stream;
    byte[] streamBuffer;
    ALuint buffer;
    AudioRenderFormats fFormat;

    // Source
    ALuint source;

public:

    /// Creates a new sound effect from an audio stream
    this(Audio audio, AudioRenderFormats format = AudioRenderFormats.Auto) {
        stream = audio;
        import std.stdio;

        // Select format if told to.
		if (format == AudioRenderFormats.Auto) {
			import std.conv;
			if (stream.info.channels == 1) fFormat = AudioRenderFormats.Mono16;
			else if (stream.info.channels == 2) fFormat = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels! " ~ stream.info.channels.to!string);
		}

        // Clear errors
        alGetError();

        // Buffer data from audio source.
        alGenBuffers(1, &buffer);
        streamBuffer = audio.readAll;
        alBufferData(buffer, fFormat, streamBuffer.ptr, cast(int)streamBuffer.length, cast(int)stream.info.bitrate);

        // Create audio source
        alGenSources(1, &source);
        alSourcei(source, AL_BUFFER, buffer);
    }

    ~this() {
        alDeleteSources(1, &source);
        alDeleteBuffers(1, &buffer);
    }

    /// Creates a new sound effect from a file.
    this(string file) {
        this(Audio(loadFile(file)), AudioRenderFormats.Auto);
    }

    void Play(bool looping = false) {
        alSourcePlay(source);
    }

	public void Pause() {
		alSourcePause(source);
	}
	
	public void Stop() {
		alSourceStop(source);
	}

	public void Rewind() {
		alSourceRewind(source);
	}

	public bool IsPlaying() {
		ALenum state;
		alGetSourcei(source, AL_SOURCE_STATE, &state);
		return (state == AL_PLAYING);
	}

	public @property bool Looping() {
		int v = 0;
		alGetSourcei(source, AL_LOOPING, &v);
		return (v == 1);
	}
	public @property void Looping(bool val) { alSourcei(source, AL_LOOPING, cast(int)val); }

	public @property int ByteOffset() {
		int v = 0;
		alGetSourcei(source, AL_BYTE_OFFSET, &v);
		return v;
	}

	public @property int SecondOffset() {
		int v = 0;
		alGetSourcei(source, AL_SEC_OFFSET, &v);
		return v;
	}

	public @property int SampleOffset() {
		int v = 0;
		alGetSourcei(source, AL_SAMPLE_OFFSET, &v);
		return v;
	}

	/*
		PITCH
	*/
	public @property float Pitch() {
		float v = 0f;
		alGetSourcef(source, AL_PITCH, &v);
		return v;
	}
	public @property void Pitch(float val) { alSourcef(source, AL_PITCH, val); }

	/*
		GAIN
	*/
	public @property float Gain() {
		float v = 0f;
		alGetSourcef(source, AL_GAIN, &v);
		return v;
	}
	public @property void Gain(float val) { alSourcef(source, AL_GAIN, val); }

	/*
		MIN GAIN
	*/
	public @property float MinGain() {
		float v = 0f;
		alGetSourcef(source, AL_MIN_GAIN, &v);
		return v;
	}
	public @property void MinGain(float val) { alSourcef(source, AL_MIN_GAIN, val); }

	/*
		MAX GAIN
	*/
	public @property float MaxGain() {
		float v = 0f;
		alGetSourcef(source, AL_MAX_GAIN, &v);
		return v;
	}
	public @property void MaxGain(float val) { alSourcef(source, AL_MAX_GAIN, val); }

	/*
		MAX DISTANCE
	*/
	public @property float MaxDistance() {
		float v = 0f;
		alGetSourcef(source, AL_MAX_DISTANCE, &v);
		return v;
	}
	public @property void MaxDistance(float val) { alSourcef(source, AL_MAX_DISTANCE, val); }

	/*
		ROLLOFF FACTOR
	*/
	public @property float RolloffFactor() {
		float v = 0f;
		alGetSourcef(source, AL_ROLLOFF_FACTOR, &v);
		return v;
	}
	public @property void RolloffFactor(float val) { alSourcef(source, AL_ROLLOFF_FACTOR, val); }

	/*
		CONE OUTER GAIN
	*/
	public @property float ConeOuterGain() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_OUTER_GAIN, &v);
		return v;
	}
	public @property void ConeOuterGain(float val) { alSourcef(source, AL_CONE_OUTER_GAIN, val); }

	/*
		CONE INNER ANGLE
	*/
	public @property float ConeInnerAngle() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_INNER_ANGLE, &v);
		return v;
	}
	public @property void ConeInnerAngle(float val) { alSourcef(source, AL_CONE_INNER_ANGLE, val); }

	/*
		CONE OUTER ANGLE
	*/
	public @property float ConeOuterAngle() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_OUTER_ANGLE, &v);
		return v;
	}
	public @property void ConeOuterAngle(float val) { alSourcef(source, AL_CONE_OUTER_ANGLE, val); }

	/*
		REFERENCE DISTANCE
	*/
	public @property float ReferenceDistance() {
		float v = 0f;
		alGetSourcef(source, AL_REFERENCE_DISTANCE, &v);
		return v;
	}
	public @property void ReferenceDistance(float val) { alSourcef(source, AL_REFERENCE_DISTANCE, val); }

	/*
		POSITION
	*/
	public @property Vector3 Position() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_POSITION, v.ptr);
		return v;
	}
	public @property void Position(Vector3 val) { alSourcefv(source, AL_POSITION, val.ptr); }

	/*
		VELOCITY
	*/
	public @property Vector3 Velocity() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_VELOCITY, v.ptr);
		return v;
	}
	public @property void Velocity(Vector3 val) { alSourcefv(source, AL_VELOCITY, val.ptr); }

	/*
		DIRECTION
	*/
	public @property Vector3 Direction() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_DIRECTION, v.ptr);
		return v;
	}
	public @property void Direction(Vector3 val) { alSourcefv(source, AL_DIRECTION, val.ptr); }

}