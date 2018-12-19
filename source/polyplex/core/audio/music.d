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

private 	__gshared Music iMus;
private 	__gshared size_t totalProcessed;
private 	__gshared ALuint deqBuff;
private 	__gshared Thread musicThread;
protected 	__gshared bool shouldStop;
private		__gshared bool started;
private		__gshared byte[] streamBuffer;
private     __gshared bool songEnded;

protected void MusicHandlerThread() {
	int buffersProcessed;
    ALint state;
    try {
	    while (!shouldStop) {
            Thread.sleep(10.msecs);
            if (iMus is null) continue;

            alGetSourcei(iMus.source, AL_BUFFERS_PROCESSED, &buffersProcessed);
            totalProcessed += buffersProcessed;
            while(buffersProcessed > 0) {
                deqBuff = 0;
                alSourceUnqueueBuffers(iMus.source, 1, &deqBuff);
                
                // Read audio from stream in
                size_t readData = iMus.stream.read(streamBuffer.ptr, iMus.bufferSize);
                if (readData == 0) {
                    if (iMus.IsLooping) {
                        iMus.stream.seek;
                        readData = iMus.stream.read(streamBuffer.ptr, iMus.bufferSize);
                    } else {
                        songEnded = true;
                    }
                }

                // Send to OpenAL
                alBufferData(deqBuff, iMus.fFormat, streamBuffer.ptr, cast(int)readData, cast(int)iMus.stream.info.bitrate);
                alSourceQueueBuffers(iMus.source, 1, &deqBuff);

                buffersProcessed--;
            }

            alGetSourcei(iMus.source, AL_SOURCE_STATE, &state);
            if (state != AL_PLAYING) {
                if (songEnded) {
                    iMus = null;
                    songEnded = false;
                    continue;
                }
                Logger.Warn("Music buffer X-run!");
                alSourcePlay(iMus.source);
            }
	    }   
    } catch(Exception ex) {
        Logger.Err("{0}", ex.message);
    }
}

protected void spawnMusicHandler() {
	started = true;
	musicThread = new Thread(&MusicHandlerThread);
	musicThread.start();
}

public class Music {
private:
    // Buffer
    Audio stream;
    ALuint[] buffer;
    AudioRenderFormats fFormat;

    int bufferSize;
    int buffers;

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
        streamBuffer = new byte[bufferSize];

        alGenBuffers(buffers, buffer.ptr);

        // Prepare sources
        alGenSources(1, &source);

        prestream();

        Logger.VerboseDebug("Created new Music! source={3} buffers={0} bufferSize={1} ids={2}", buffers, bufferSize, buffer, source);

		if (!started) spawnMusicHandler();
    }

    private void prestream() {
        // Pre-read some data.
        foreach (i; 0 .. buffers) {
			// Read audio from stream in
			size_t read = stream.read(streamBuffer.ptr, bufferSize);

			// Send to OpenAL
			alBufferData(buffer[i], this.fFormat, streamBuffer.ptr, cast(int)read, cast(int)stream.info.bitrate);
			alSourceQueueBuffers(source, 1, &buffer[i]);
        }
    }
    
    void Play() {
		synchronized {
			if (iMus !is null) iMus.Stop();
			iMus = this;
			alSourcePlay(source);
		}
    }

    void Stop() {
		synchronized {
			iMus = null;
			alSourceStop(source);
			stream.seek();
			prestream();
		}
    }

    size_t Tell() {
		synchronized { 
			return stream.tell;
		}
    }

    bool isThreadRunning() {
        return musicThread.isRunning;
    }

    bool IsLooping;
}