module polyplex.core.audio.music;
import polyplex.core.audio;
import ppc.types.audio;
import derelict.openal;
import ppc.backend.cfile;
import polyplex.math;
import std.concurrency;
import std.stdio;
import polyplex.utils.logging;
import core.thread;
import core.time;
import core.sync.mutex;

protected 	__gshared bool shouldStop;

protected void MusicHandlerThread(Music iMus) {
    try {
		int buffersProcessed;
		ALuint deqBuff;
		ALint state;
		byte[] streamBuffer = new byte[iMus.bufferSize];
	    while (!shouldStop && !iMus.shouldStopInternal) {
            Thread.sleep(10.msecs);

            alGetSourcei(iMus.source, AL_BUFFERS_PROCESSED, &buffersProcessed);
            iMus.totalProcessed += buffersProcessed;

            while(buffersProcessed > 0) {
                deqBuff = 0;
                alSourceUnqueueBuffers(iMus.source, 1, &deqBuff);

                // Read audio from stream in
                size_t readData = iMus.stream.read(streamBuffer.ptr, iMus.bufferSize);
                if (readData == 0) {
                    if (!iMus.looping) return; 
					iMus.stream.seek;
					readData = iMus.stream.read(streamBuffer.ptr, iMus.bufferSize);
                }

                // Send to OpenAL
                alBufferData(deqBuff, iMus.fFormat, streamBuffer.ptr, cast(int)readData, cast(int)iMus.stream.info.bitrate);
                alSourceQueueBuffers(iMus.source, 1, &deqBuff);

                buffersProcessed--;
            }

            alGetSourcei(iMus.source, AL_SOURCE_STATE, &state);
            if (state != AL_PLAYING) {
                Logger.Warn("Music buffer X-run!");
                alSourcePlay(iMus.source);
            }
	    }   
    } catch(Exception ex) {
        Logger.Err("{0}", ex.message);
    }
}

public class Music {
private:
    size_t totalProcessed;
    Thread musicThread;
    bool shouldStopInternal;

    // Buffer
    Audio stream;
    ALuint[] buffer;
    AudioRenderFormats fFormat;

    int bufferSize;
    int buffers;

    bool looping;

	int boundChannel = -1;

    // Source
    ALuint source;

public:

    this(Audio audio, AudioRenderFormats format = AudioRenderFormats.Auto, int buffers = 16) {
        stream = audio;
		
        // Select format if told to.
		if (format == AudioRenderFormats.Auto) {
			import std.conv;
			if (stream.info.channels == 1) fFormat = AudioRenderFormats.Mono16;
			else if (stream.info.channels == 2) fFormat = AudioRenderFormats.Stereo16;
			else throw new Exception("Unsupported amount of channels! " ~ stream.info.channels.to!string);
		}

        // Clear errors
        alGetError();

        // Prepare buffer arrays
        this.buffers = buffers;
        buffer = new ALuint[buffers];

        this.bufferSize = cast(int)stream.info.bitrate*stream.info.channels;

        alGenBuffers(buffers, buffer.ptr);

        // Prepare sources
        alGenSources(1, &source);

        prestream();

        Logger.VerboseDebug("Created new Music! source={3} buffers={0} bufferSize={1} ids={2}", buffers, bufferSize, buffer, source);
    }

    ~this() {
        // Cleanup procedure
        alDeleteSources(1, &source);
        alDeleteBuffers(buffers, buffer.ptr);
    }

    private void prestream() {
		byte[] streamBuffer = new byte[bufferSize];

        // Pre-read some data.
        foreach (i; 0 .. buffers) {
			// Read audio from stream in
			size_t read = stream.read(streamBuffer.ptr, bufferSize);

			// Send to OpenAL
			alBufferData(buffer[i], this.fFormat, streamBuffer.ptr, cast(int)read, cast(int)stream.info.bitrate);
			alSourceQueueBuffers(source, 1, &buffer[i]);
        }
    }

	private void spawnHandler() {
		if (musicThread !is null && musicThread.isRunning) return;

		musicThread = new Thread({
			MusicHandlerThread(this);
		});
		musicThread.start();
	}

    void Play() {
		synchronized {
			if (musicThread is null || !musicThread.isRunning) spawnHandler();
			alSourcePlay(source);
		}
    }

    void Stop() {
		synchronized {
			if (musicThread is null) return;

			// Tell thread to die, repeatedly until it does.
			while(musicThread.isRunning) shouldStopInternal = true;

			// Stop source and prepare for playing again
			alSourceStop(source);
			stream.seek();
			prestream();
		}
    }

	void Pause() {
		alSourcePause(source);
	}

    size_t Tell() {
		synchronized { 
			return stream.tell;
		}
    }

	public @property bool Looping() {
		return looping;
	}
	public @property void Looping(bool val) { looping = val; }
	
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