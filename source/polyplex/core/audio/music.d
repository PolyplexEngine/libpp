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

// This is set to true on application close, so that threads know to quit.
protected 	__gshared bool shouldStop;

protected void MusicHandlerThread(Music iMus) {
    try {
		int buffersProcessed;
		ALuint deqBuff;
		ALint state;
		byte[] streamBuffer = new byte[iMus.bufferSize];

        // Stop thread if requested.
	    while (!shouldStop && !iMus.shouldStopInternal) {

            // Sleep needed to make the CPU NOT run at 100% at all times
            Thread.sleep(10.msecs);

            // Check if we have any buffers to fill
            alGetSourcei(iMus.source, AL_BUFFERS_PROCESSED, &buffersProcessed);
            iMus.totalProcessed += buffersProcessed;
            while(buffersProcessed > 0) {

                // Find the ID of the buffer to fill
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

            // OpenAL will stop the stream if it runs out of buffers
            // Ensure that if OpenAL stops, we start it again.
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
    // Internal thread-communication data.
    size_t totalProcessed;
    Thread musicThread;
    bool shouldStopInternal;

    // Buffer
    Audio stream;
    ALuint[] buffer;
    AudioRenderFormats fFormat;

    // Buffer sizing
    int bufferSize;
    int buffers;

    // Settings
    bool looping;
    bool paused;

    // Source
    ALuint source;

public:

    /// Constructs a Music via an Audio source.
    // TODO: Optimize enough so that we can have fewer buffers
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

    // Spawns player thread.
	private void spawnHandler() {
		if (musicThread !is null && musicThread.isRunning) return;

		musicThread = new Thread({
			MusicHandlerThread(this);
		});
		musicThread.start();
	}

    /// Play music
    void Play(bool isLooping = false) {
		synchronized {
			if (musicThread is null || !musicThread.isRunning) spawnHandler();
            alSourcePlay(source);
            paused = false;
		}
    }

    /// Stop playing music
    /// Does nothing if music isn't playing.
    void Stop() {
		synchronized {
			if (musicThread is null) return;

			// Tell thread to die repeatedly, until it does.
			while(musicThread.isRunning) shouldStopInternal = true;

			// Stop source and prepare for playing again
			alSourceStop(source);
			stream.seek();
			prestream();
		}
    }

    /// Pause music
	void Pause() {
        synchronized {
		    alSourcePause(source);
            paused = true;
        }
	}

    /// Gets the current position in the music stream (in samples)
    size_t Tell() {
		synchronized { 
			return stream.tell;
		}
    }

    /// Seeks the music stream (in samples)
    void Seek(size_t position = 0) {
        synchronized {
            if (position >= Length) position = Length-1;
            // Pause stream
            Pause();

            // Unqueue everything
            alSourceUnqueueBuffers(source, buffers, buffer.ptr);

            // Refill buffers
            stream.seekSample(position);
            prestream();

            // Resume
            alSourcePlay(source);
        }
    }

    /// Gets length of music (in samples)
    size_t Length() {
        return stream.info.pcmLength;
    }

    /// Gets wether the music is paused.
    public bool Paused() {
        return paused;
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