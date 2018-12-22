module polyplex.core.audio.effect;
public import polyplex.core.audio.effects;
public import polyplex.core.audio.filters;
import openal;

enum EffectType : ALenum {
    Nothing             = AL_EFFECT_NULL,
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

public:
    
    this(EffectType eType) {
        alGenEffects(1, &id);
        alGenAuxiliaryEffectSlots(1, &sendId);
        this.effectType = eType;
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