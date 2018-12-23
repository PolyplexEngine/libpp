module polyplex.core.audio.effect;
public import polyplex.core.audio.effects;
public import polyplex.core.audio.filters;
public import polyplex.core.audio;
import openal;

enum EffectType : ALenum {
    Nothing             = AL_EFFECT_NULL,
    RoomDynamics        = AL_EFFECT_EAXREVERB,
    Reverb              = AL_EFFECT_REVERB,
    Chorus              = AL_EFFECT_CHORUS,
    Distortion          = AL_EFFECT_DISTORTION,
    Echo                = AL_EFFECT_ECHO,
    Flanger             = AL_EFFECT_FLANGER,
    FreqencyShifter     = AL_EFFECT_FREQUENCY_SHIFTER,
    VocalMorpher        = AL_EFFECT_VOCAL_MORPHER,
    PitchShifter        = AL_EFFECT_PITCH_SHIFTER,
    RingModulation      = AL_EFFECT_RING_MODULATOR,
    AutoWah             = AL_EFFECT_AUTOWAH,
    Compressor          = AL_EFFECT_COMPRESSOR,
    Equalizer           = AL_EFFECT_EQUALIZER
}

enum FilterType : ALenum {
    Nothing             = AL_FILTER_NULL,
    Lowpass             = AL_FILTER_LOWPASS,
    Highpass            = AL_FILTER_HIGHPASS,
    Bandpass            = AL_FILTER_BANDPASS
}

public class AudioEffect {
protected:
    ALuint id;
    ALuint sendId;
    EffectType effectType;

    void setupDone() {
        alAuxiliaryEffectSloti(sendId, AL_EFFECTSLOT_EFFECT, id);
    }

public:
    
    this(EffectType eType) {
        alGenEffects(1, &id);
        alGenAuxiliaryEffectSlots(1, &sendId);
        this.effectType = eType;

        alEffecti(id, AL_EFFECT_TYPE, cast(ALenum)eType);

		import std.conv;
        ErrCodes err = cast(ErrCodes)alGetError();
		if (cast(ALint)err != AL_NO_ERROR) throw new Exception("Failed to create object "~err.to!string);
    }

    ~this() {
        alDeleteAuxiliaryEffectSlots(1, &sendId);
        alDeleteEffects(1, &id);
    }

    ALuint Id() {
        return sendId;
    }

    ALuint RawId() {
        return id;
    }

    EffectType Type() {
        return effectType;
    }
}

public class AudioFilter {
protected:
    ALuint id;
    FilterType filterType;

public:
    this(FilterType fType) {
        alGenFilters(1, &id);
        this.filterType = fType;

        alFilteri(id, AL_FILTER_TYPE, cast(ALenum)fType);

		import std.conv;
        ErrCodes err = cast(ErrCodes)alGetError();
		if (cast(ALint)err != AL_NO_ERROR) throw new Exception("Failed to create object "~err.to!string);
    }

    ~this() {
        alDeleteFilters(1, &id);
    }

    ALuint Id() {
        return id;
    }

    FilterType Type() {
        return filterType;
    }

}