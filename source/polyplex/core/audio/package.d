module polyplex.core.audio;
import polyplex.utils.logging;
import openal;
public import polyplex.core.audio.soundeffect;
public import polyplex.core.audio.music;
public import polyplex.core.audio.syncgroup;
public import polyplex.core.audio.effect;

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

public enum ALExtensionSupport {
	/**
		Basic OpenAL context is supported.
	*/
	Basic = 0x00,

	/**
		EAX 2.0 is supported.
	*/
	EAX2 = 0x01,

	/**
		EFX is supported.
	*/
	EFX = 0x02,

	/**
		OpenAL-Soft effect chaining
	*/
	EffectChaining = 0x04
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

protected __gshared ALint maxSlots;

public class AudioDevice {
	private static bool deviceCreationSucceeded;
	public ALCdevice* ALDevice;
	public ALCcontext* ALContext;
	private static ALExtensionSupport supportedExtensions;
	public static ALint MixerSize = 10;

	public static bool DeviceCreationSucceeded() {
		return deviceCreationSucceeded;
	}

	public static ALExtensionSupport SupportedExtensions() {
		return supportedExtensions;
	}

	/**
		Constucts an audio device, NULL for preffered device.
	*/
	this(string device = null) {
		ALint[] attribs = null;

		Logger.Info("Initializing OpenAL device...");
		ALCdevice* dev = alcOpenDevice(device.ptr);
		
		// If EAX 2.0 is supported, flag it as supported.
		bool supex = cast(bool)alIsExtensionPresent("EAX2.0");
		if (supex) {
			Logger.Success("EAX 2.0 extensions are supported!");
			supportedExtensions |= ALExtensionSupport.EAX2;
		}

		// If EFX is supported, flag it as supported.
		supex = cast(bool)alcIsExtensionPresent(dev, "ALC_EXT_EFX");
		if (supex) {
			supportedExtensions |= ALExtensionSupport.EFX;
			Logger.Success("EFX extensions are supported!");
			Logger.Info("Setting up mixer channel count...");
			attribs = new ALint[4];
			attribs[0] = ALC_MAX_AUXILIARY_SENDS;
			attribs[1] = MixerSize;
		}

		// If Effect Chaining is supported, flag it as supported.
		supex = cast(bool)alcIsExtensionPresent(dev, "AL_SOFTX_effect_chain");
		if (supex) {
			supportedExtensions |= ALExtensionSupport.EffectChaining;
			Logger.Success("Effect chains are supported!");
		}

		if (dev) {
			ALContext = alcCreateContext(dev, attribs.ptr);
			alcMakeContextCurrent(ALContext);
		} else {
			import std.conv;
			import std.stdio;
			Logger.Err("Could not create device! {0}", (cast(ErrCodes)alcGetError(dev)).to!string);
			deviceCreationSucceeded = false;
			return;
		}
		if (supex) {
			ALint sourceMax;
			alcGetIntegerv(dev, ALC_MAX_AUXILIARY_SENDS, 1, &sourceMax);

			maxSlots = sourceMax;

			Logger.Info("Created {0} mixer sends", sourceMax);
		}
		deviceCreationSucceeded = true;
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
}