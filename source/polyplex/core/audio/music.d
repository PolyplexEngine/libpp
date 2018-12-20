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
protected 	__gshared int openMusicChannels;

private void iHandlerLaunch() {
	synchronized {
		openMusicChannels++;
	}
}

private void iHandlerStop() {
	synchronized {
		openMusicChannels--;
	}
}

protected void MusicHandlerThread(Music iMus) {
    try {
		iHandlerLaunch;
		int buffersProcessed;
		ALuint deqBuff;
		ALint state;
		byte[] streamBuffer = new byte[iMus.bufferSize];

		size_t startBufferSize = Music.BufferSize;

        // Stop thread if requested.
	    while (iMus !is null && &shouldStop !is null && !shouldStop && !iMus.shouldStopInternal) {

            // Sleep needed to make the CPU NOT run at 100% at all times
            Thread.sleep(10.msecs);

            // Check if we have any buffers to fill
            alGetSourcei(iMus.source, AL_BUFFERS_PROCESSED, &buffersProcessed);
            iMus.totalProcessed += buffersProcessed;
            while(buffersProcessed > 0) {

                // Find the ID of the buffer to fill
                deqBuff = 0;
                alSourceUnqueueBuffers(iMus.source, 1, &deqBuff);

				// Resize buffers if needed
				if (startBufferSize != Music.BufferSize) {
					streamBuffer.length = Music.BufferSize;
					startBufferSize = Music.BufferSize;
					iMus.bufferSize = cast(int)Music.BufferSize;
				}

                // Read audio from stream in
                size_t readData = iMus.stream.read(streamBuffer.ptr, iMus.bufferSize);
                if (readData == 0) {
                    if (!iMus.looping) {
						iMus.playing = false;
						return; 
					}
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
				iMus.xruns++;
                Logger.Warn("Music buffer X-run!");
                alSourcePlay(iMus.source);
            }
	    }   
    } catch(Exception ex) {
        Logger.Err("MusicHandlerException: {0}", ex.message);
    } catch (Error err) {
        Logger.Err("MusicHandlerError: {0}", err.message);
	}
	iHandlerStop;
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
	bool playing;

	int xruns;

    // Source
    ALuint source;

public:

	/// Changes the size of the buffers for music playback.
	/// Changes take effect immidiately
	static size_t BufferSize = 48_000;

	/// Amount of buffers to provision per audio track
	/// Takes effect on new audio load.
	static size_t BufferCount = 16;

    /// Constructs a Music via an Audio source.
    // TODO: Optimize enough so that we can have fewer buffers
    this(Audio audio, AudioRenderFormats format = AudioRenderFormats.Auto) {
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
        this.buffers = cast(int)BufferCount;
        buffer = new ALuint[buffers];

        this.bufferSize = (cast(int)BufferSize)*stream.info.channels;

        alGenBuffers(buffers, buffer.ptr);

        // Prepare sources
        alGenSources(1, &source);

        prestream();

        Logger.VerboseDebug("Created new Music! source={3} buffers={0} bufferSize={1} ids={2}", buffers, bufferSize, buffer, source);
    }

    ~this() {
        cleanup();
    }

	private void cleanup() {
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
			playing = true;
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

			playing = false;
		}
    }

    /// Pause music
	void Pause() {
        synchronized {
		    alSourcePause(source);
            paused = true;
			playing = false;
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
            // Stop stream
            alSourceStop(source);

            // Unqueue everything
            alSourceUnqueueBuffers(source, buffers, buffer.ptr);

            // Refill buffers
            stream.seekSample(position);
            prestream();

            // Resume
            if (playing) alSourcePlay(source);
        }
    }

    /// Gets length of music (in samples)
    size_t Length() {
        return stream.info.pcmLength;
    }

	/// Get amount of unhandled XRuns that has happened.
	int XRuns() {
		synchronized {
			return xruns;
		}
	}

	/// Mark XRuns as handled.
	void HandledXRun() {
		synchronized {
			xruns = 0;
		}
	}

    /// Gets wether the music is paused.
    bool Paused() {
        return paused;
    }

	/// Gets wether the music is playing
	bool Playing() {
		return playing;
	}

	@property bool Looping() {
		return looping;
	}
	@property void Looping(bool val) { looping = val; }
	
	/*
		PITCH
	*/
	@property float Pitch() {
		float v = 0f;
		alGetSourcef(source, AL_PITCH, &v);
		return v;
	}
	@property void Pitch(float val) { alSourcef(source, AL_PITCH, val); }

	/*
		GAIN
	*/
	@property float Gain() {
		float v = 0f;
		alGetSourcef(source, AL_GAIN, &v);
		return v;
	}
	@property void Gain(float val) { alSourcef(source, AL_GAIN, val); }

	/*
		MIN GAIN
	*/
	@property float MinGain() {
		float v = 0f;
		alGetSourcef(source, AL_MIN_GAIN, &v);
		return v;
	}
	@property void MinGain(float val) { alSourcef(source, AL_MIN_GAIN, val); }

	/*
		MAX GAIN
	*/
	@property float MaxGain() {
		float v = 0f;
		alGetSourcef(source, AL_MAX_GAIN, &v);
		return v;
	}
	@property void MaxGain(float val) { alSourcef(source, AL_MAX_GAIN, val); }

	/*
		MAX DISTANCE
	*/
	@property float MaxDistance() {
		float v = 0f;
		alGetSourcef(source, AL_MAX_DISTANCE, &v);
		return v;
	}
	@property void MaxDistance(float val) { alSourcef(source, AL_MAX_DISTANCE, val); }

	/*
		ROLLOFF FACTOR
	*/
	@property float RolloffFactor() {
		float v = 0f;
		alGetSourcef(source, AL_ROLLOFF_FACTOR, &v);
		return v;
	}
	@property void RolloffFactor(float val) { alSourcef(source, AL_ROLLOFF_FACTOR, val); }

	/*
		CONE OUTER GAIN
	*/
	@property float ConeOuterGain() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_OUTER_GAIN, &v);
		return v;
	}
	@property void ConeOuterGain(float val) { alSourcef(source, AL_CONE_OUTER_GAIN, val); }

	/*
		CONE INNER ANGLE
	*/
	@property float ConeInnerAngle() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_INNER_ANGLE, &v);
		return v;
	}
	@property void ConeInnerAngle(float val) { alSourcef(source, AL_CONE_INNER_ANGLE, val); }

	/*
		CONE OUTER ANGLE
	*/
	@property float ConeOuterAngle() {
		float v = 0f;
		alGetSourcef(source, AL_CONE_OUTER_ANGLE, &v);
		return v;
	}
	@property void ConeOuterAngle(float val) { alSourcef(source, AL_CONE_OUTER_ANGLE, val); }

	/*
		REFERENCE DISTANCE
	*/
	@property float ReferenceDistance() {
		float v = 0f;
		alGetSourcef(source, AL_REFERENCE_DISTANCE, &v);
		return v;
	}
	@property void ReferenceDistance(float val) { alSourcef(source, AL_REFERENCE_DISTANCE, val); }

	/*
		POSITION
	*/
	@property Vector3 Position() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_POSITION, v.ptr);
		return v;
	}
	@property void Position(Vector3 val) { alSourcefv(source, AL_POSITION, val.ptr); }

	/*
		VELOCITY
	*/
	@property Vector3 Velocity() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_VELOCITY, v.ptr);
		return v;
	}
	@property void Velocity(Vector3 val) { alSourcefv(source, AL_VELOCITY, val.ptr); }

	/*
		DIRECTION
	*/
	@property Vector3 Direction() {
		Vector3 v = 0f;
		alGetSourcefv(source, AL_DIRECTION, v.ptr);
		return v;
	}
	@property void Direction(Vector3 val) { alSourcefv(source, AL_DIRECTION, val.ptr); }
}