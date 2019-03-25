module audio.effect;
public import audio.effects;
public import audio.filters;
public import audio;
import std.algorithm.searching;
import std.array;
import std.algorithm.mutation : remove;
import openal;

private enum ErrorNotOpenAlSoftRouting = "Chaining effects together is not supported on the current OpenAL implementation

    -   Try using OpenAL-Soft which is open source.";

//// Types of effects supported.
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

/// Types of filters supported
enum FilterType : ALenum {
    Nothing             = AL_FILTER_NULL,
    Lowpass             = AL_FILTER_LOWPASS,
    Highpass            = AL_FILTER_HIGHPASS,
    Bandpass            = AL_FILTER_BANDPASS
}

/**
    A realtime audio effect
    Some audio effects might not be available on some systems.
    If an effect is not available an error will be logged and the effect ignored.

    With OpenAL-Soft effect routing is supported
    You **CAN'T** route an effect back to itself.

    You will need OpenAL-Soft installed or EFX extensions.
*/
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
        if (!(supportedExtensions & ALExtensionSupport.EFX)) {
            return;
        }

        // clear errors
        alGetError();

        alGenEffects(1, &id);
        alGenAuxiliaryEffectSlots(1, &sendId);
        this.effectType = eType;

        alEffecti(id, AL_EFFECT_TYPE, cast(ALenum)eType);

		import std.conv;
        ErrCodes err = cast(ErrCodes)alGetError();
		if (cast(ALint)err != AL_NO_ERROR) throw new Exception("Failed to create object "~err.to!string);
    }

    ~this() {
        if (!(supportedExtensions & ALExtensionSupport.EFX)) {
            return;
        }
        if (supportedExtensions & ALExtensionSupport.EffectChaining) {
            // Be SURE to unmap this effect from something else.
            // Prevents OpenAL crashing in some instances.
            deattachAllChildren();
            unbind();
        }
        alDeleteAuxiliaryEffectSlots(1, &sendId);
        alDeleteEffects(1, &id);
    }

    /// Returns the ID of this effect.
    ALuint Id() {
        return sendId;
    }

    /// Returns the raw (non-send) ID of this effect.
    ALuint RawId() {
        return id;
    }

    /// Returns the type of this effect.
    EffectType Type() {
        return effectType;
    }

    /**
        Attach sound effect to another.

        A sound effect can only attach to one other sound effect.
        
        A sound effect can be attached to by many others.
    */
    void AttachTo(AudioEffect effect) {
        if (!(supportedExtensions & ALExtensionSupport.EffectChaining)) {
            throw new Exception(ErrorNotOpenAlSoftRouting);
        }

        // Unaffiliate self with previous parent when change is requested.
        if (target !is null) {
            target.deattachChild(this);
        }

        // Bind to new effect.
        bind(effect.Id);
        effect.attach(this);
    }

    /**
        Deattaches the sound effect from ALL other sound effects.
    */
    void Deattach() {
        if (!(supportedExtensions & ALExtensionSupport.EffectChaining)) {
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

/**
    An audio filter, various filters are supported

    A filter modifies which frequencies of audio are sent through.

    You can only have 1 filter applied at a time, applying a new filter will overwrite the old selection.

    You will need OpenAL-Soft installed or EFX extensions.
*/
public class AudioFilter {
protected:
    ALuint id;
    FilterType filterType;

public:
    this(FilterType fType) {
        if (!(supportedExtensions & ALExtensionSupport.EFX)) {
            return;
        }
        alGenFilters(1, &id);
        this.filterType = fType;

        alFilteri(id, AL_FILTER_TYPE, cast(ALenum)fType);

		import std.conv;
        ErrCodes err = cast(ErrCodes)alGetError();
		if (cast(ALint)err != AL_NO_ERROR) throw new Exception("Failed to create object "~err.to!string);
    }

    ~this() {
        if (!(supportedExtensions & ALExtensionSupport.EFX)) {
            return;
        }
        alDeleteFilters(1, &id);
    }

    /// Returns the ID of this filter.
    ALuint Id() {
        return id;
    }

    /// Returns the type of this filter.
    FilterType Type() {
        return filterType;
    }

}