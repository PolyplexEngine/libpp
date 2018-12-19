module polyplex.core.audio;
import derelict.openal;
public import polyplex.core.audio.soundeffect;
public import polyplex.core.audio.music;

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