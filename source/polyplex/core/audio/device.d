module polyplex.core.audio.device;
import polyplex.core.audio;
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

public class AudioDevice {
	public ALCDevice* ALDevice;
	public ALCcontext* ALContext;
	public ALExtensionSupport SupportedExt;

	/**
		Constucts an audio device, NULL for preffered device.
	*/
	this(void* device = null) {
		ALCDevice* dev = alcOpenDevice(device);
		if (dev) {
			ALContext = alcCreateContext(dev, null);
			alcMakeContextCurrent(ALContext);
		}
		
		// If EAX 2.0 is supported, flag it as supported.
		bool supex = alIsExtensionPresent("EAX2.0");
		if (supex) SupportedExt |= ALExtensionSupport.EAX2;
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