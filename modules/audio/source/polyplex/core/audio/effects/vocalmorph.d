module polyplex.core.audio.effects.vocalmorph;
import polyplex.core.audio.effects;
import polyplex.core.audio.effect;
import openal;

enum Phoneme : ALenum {
    A = AL_VOCAL_MORPHER_PHONEME_A,
    E = AL_VOCAL_MORPHER_PHONEME_E,
    I = AL_VOCAL_MORPHER_PHONEME_I,
    O = AL_VOCAL_MORPHER_PHONEME_O,
    U = AL_VOCAL_MORPHER_PHONEME_U,

    AA = AL_VOCAL_MORPHER_PHONEME_AA,
    AE = AL_VOCAL_MORPHER_PHONEME_AE,
    AH = AL_VOCAL_MORPHER_PHONEME_AH,
    AO = AL_VOCAL_MORPHER_PHONEME_AO,

    EH = AL_VOCAL_MORPHER_PHONEME_EH,
    ER = AL_VOCAL_MORPHER_PHONEME_ER,

    IH = AL_VOCAL_MORPHER_PHONEME_IH,
    IY = AL_VOCAL_MORPHER_PHONEME_IY,

    UH = AL_VOCAL_MORPHER_PHONEME_UH,
    UW = AL_VOCAL_MORPHER_PHONEME_UW,

    B = AL_VOCAL_MORPHER_PHONEME_B,
    D = AL_VOCAL_MORPHER_PHONEME_D,
    F = AL_VOCAL_MORPHER_PHONEME_F,
    G = AL_VOCAL_MORPHER_PHONEME_G,
    J = AL_VOCAL_MORPHER_PHONEME_J,
    K = AL_VOCAL_MORPHER_PHONEME_K,
    L = AL_VOCAL_MORPHER_PHONEME_L,
    M = AL_VOCAL_MORPHER_PHONEME_M,
    N = AL_VOCAL_MORPHER_PHONEME_N,
    P = AL_VOCAL_MORPHER_PHONEME_P,
    R = AL_VOCAL_MORPHER_PHONEME_R,
    S = AL_VOCAL_MORPHER_PHONEME_S,
    T = AL_VOCAL_MORPHER_PHONEME_T,
    V = AL_VOCAL_MORPHER_PHONEME_V,
    Z = AL_VOCAL_MORPHER_PHONEME_Z,
}

/**
    A 4-band formant filter, allowing to morph vocal-ish texture in to sound.

    WARNING: Only few *hardware* OpenAL implementations support this currently.
*/
public class VocalMorpherEffect : AudioEffect {
public:
    this() {
        super(EffectType.VocalMorpher);
        setupDone();
    }

    @property Phoneme PhonemeA() {
        ALenum val;
        alGetEffecti(id, AL_VOCAL_MORPHER_PHONEMEA, &val);
        return cast(Phoneme)val;
    }

    @property void PhonemeA(Phoneme val) {
        alEffecti(id, AL_VOCAL_MORPHER_PHONEMEA, cast(ALuint)val);
    }

    @property float TuningA() {
        ALfloat val;
        alGetEffectf(id, AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING, &val);
        return val;
    }

    @property void TuningA(ALfloat val) {
        alEffectf(id, AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING, val);
    }

    @property Phoneme PhonemeB() {
        ALenum val;
        alGetEffecti(id, AL_VOCAL_MORPHER_PHONEMEB, &val);
        return cast(Phoneme)val;
    }

    @property void PhonemeB(Phoneme val) {
        alEffecti(id, AL_VOCAL_MORPHER_PHONEMEB, cast(ALuint)val);
    }

    @property float TuningB() {
        ALfloat val;
        alGetEffectf(id, AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING, &val);
        return val;
    }

    @property void TuningB(ALfloat val) {
        alEffectf(id, AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING, val);
    }

    @property WaveformType Waveform() {
        ALenum val;
        alGetEffecti(id, AL_VOCAL_MORPHER_WAVEFORM, &val);
        return cast(WaveformType)val;
    }

    @property void Waveform(WaveformType val) {
        alEffecti(id, AL_VOCAL_MORPHER_WAVEFORM, cast(ALuint)val);
    }

    @property float Rate() {
        ALfloat val;
        alGetEffectf(id, AL_VOCAL_MORPHER_RATE, &val);
        return val;
    }

    @property void Rate(ALfloat val) {
        alEffectf(id, AL_VOCAL_MORPHER_RATE, val);
    }
}