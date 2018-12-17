module polyplex.core.audio.al.device;
import polyplex.core.audio.al;
import ppc.types.audio;
import derelict.openal;

public enum ALExtensionSupport {
	/**
		Basic OpenAL context is supported.
	*/
	Basic = 0x00,

	/**
		EAX 2.0 is supported.
	*/
	EAX2 = 0x01
	// TODO add more extensions here.
}

public static AudioDevice DefaultAudioDevice;

//TODO: remove this
enum ErrCodes : ALCenum {
	ALC_FREQUENCY           = 0x1007,
    ALC_REFRESH             = 0x1008,
    ALC_SYNC                = 0x1009,

    ALC_MONO_SOURCES        = 0x1010,
    ALC_STEREO_SOURCES      = 0x1011,

    ALC_NO_ERROR            = ALC_FALSE,
    ALC_INVALID_DEVICE      = 0xA001,
    ALC_INVALID_CONTEXT     = 0xA002,
    ALC_INVALID_ENUM        = 0xA003,
    ALC_INVALID_VALUE       = 0xA004,
    ALC_OUT_OF_MEMORY       = 0xA005,

    ALC_DEFAULT_DEVICE_SPECIFIER        = 0x1004,
    ALC_DEVICE_SPECIFIER                = 0x1005,
    ALC_EXTENSIONS                      = 0x1006,

    ALC_MAJOR_VERSION                   = 0x1000,
    ALC_MINOR_VERSION                   = 0x1001,

    ALC_ATTRIBUTES_SIZE                 = 0x1002,
    ALC_ALL_ATTRIBUTES                  = 0x1003,

    ALC_CAPTURE_DEVICE_SPECIFIER            = 0x310,
    ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER    = 0x311,
    ALC_CAPTURE_SAMPLES                     = 0x312,
}

public class AudioDevice {
	public ALCdevice* ALDevice;
	public ALCcontext* ALContext;
	public ALExtensionSupport SupportedExt;

	/**
		Constucts an audio device, NULL for preffered device.
	*/
	this(string device = null) {
		ALCdevice* dev = alcOpenDevice(device.ptr);
		if (dev) {
			ALContext = alcCreateContext(dev, null);
			alcMakeContextCurrent(ALContext);
		} else {
			import std.conv;
			import std.stdio;
			throw new Exception("Could not create device! " ~ (cast(ErrCodes)alcGetError(dev)).to!string);
		}
		
		// If EAX 2.0 is supported, flag it as supported.
		bool supex = cast(bool)alIsExtensionPresent("EAX2.0");
		if (supex) SupportedExt |= ALExtensionSupport.EAX2;
	}

	~this() {
		alcMakeContextCurrent(null);
		alcDestroyContext(ALContext);
		alcCloseDevice(ALDevice);
	}

	/**
		Makes the context for this device, a current context.
	*/
	public void MakeCurrent() {
		alcMakeContextCurrent(ALContext);
	}

	public ALBuffer GenerateBuffer(Audio aud) {
		return new ALBuffer(aud);
	}
}