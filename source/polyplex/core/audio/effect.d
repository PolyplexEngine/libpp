module polyplex.core.audio.effect;
public import polyplex.core.audio.effects;
public import polyplex.core.audio.filters;
public import polyplex.core.audio;
import std.algorithm.searching;
import std.array;
import std.algorithm.mutation : remove;
import openal;

private enum ErrorNotOpenAlSoftRouting = "Chaining effects together is not supported on the current OpenAL implementation

    -   Try using OpenAL-Soft which is open source.";

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

    AudioEffect target = null;
    AudioEffect[] attachedEffects;

    void setupDone() {
        alAuxiliaryEffectSloti(sendId, AL_EFFECTSLOT_EFFECT, id);
    }

    void deattachAllChildren() {
        foreach (effect; attachedEffects) {
            effect.unbind();
        }
        attachedEffects.length = 0;
    }

    void attach(AudioEffect effect) {
        if (!effect.attachedEffects.canFind(this)) {
            effect.attachedEffects ~= this;
        }
        target = effect;
    }

    void deattachChild(AudioEffect effect) {
        if (attachedEffects.canFind(effect)) {
            attachedEffects.remove(attachedEffects.countUntil(effect));
        }
        effect.unbind();
    }

    void bind(ALuint id) {
        alAuxiliaryEffectSloti(Id, AL_EFFECTSLOT_TARGET_SOFT, id);
    }

    void unbind() {
        bind(0);
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
        if (AudioDevice.SupportedExt & ALExtensionSupport.EffectChaining) {
            // Be SURE to unmap this effect from something else.
            // Prevents OpenAL crashing in some instances.
            deattachAllChildren();
            unbind();
        }
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

    /**
        Attach sound effect to another.

        A sound effect can only attach to one other sound effect.
        
        A sound effect can be attached to by many others.
    */
    void AttachTo(AudioEffect effect) {
        if (!(AudioDevice.SupportedExt & ALExtensionSupport.EffectChaining)) {
            throw new Exception(ErrorNotOpenAlSoftRouting);
        }

        // Unaffiliate self with previous parent when change is requested.
        if (target !is null) {
            effect.deattachChild(this);
        }

        // Bind to new effect.
        bind(effect.Id);
        effect.attach(this);
    }

    /**
        Deattaches the sound effect from ALL other sound effects.
    */
    void Deattach() {
        if (!(AudioDevice.SupportedExt & ALExtensionSupport.EffectChaining)) {
            throw new Exception(ErrorNotOpenAlSoftRouting);
        }
        // Skip all the unbinding as it's not neccesary, small optimization.
        if (target is null) {
            return;
        }
        unbind();
        target.deattachChild(this);
        target = null;
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