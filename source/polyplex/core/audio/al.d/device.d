module polyplex.core.audio.al.device;
import polyplex.core.audio.al;
import ppc.audio;
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
			throw new Exception("Could not create device!");
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