module polyplex.core.audio.soundeffect;
import polyplex.core.audio;
import ppc.types.audio;
import derelict.openal;
import ppc.backend.cfile;

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
        writeln(streamBuffer.ptr, " ", streamBuffer.length);
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
}