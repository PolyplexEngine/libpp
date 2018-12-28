module polyplex.core.audio.effects.flanger;
import polyplex.core.audio.effects;
import polyplex.core.audio.effect;
import openal;

/// A Flanger
public class FlangerEffect : AudioEffect {
public:
    this() {
        super(EffectType.Flanger);
        setupDone();
    }

    @property WaveformType Waveform() {
        ALenum val;
        alGetEffecti(id, AL_FLANGER_WAVEFORM, &val);
        return cast(WaveformType)val;
    }

    @property void Waveform(WaveformType val) {
        alEffecti(id, AL_FLANGER_WAVEFORM, cast(ALuint)val);
    }

    @property int Phase() {
        ALint val;
        alGetEffecti(id, AL_FLANGER_PHASE, &val);
        return cast(int)val;
    }

    @property void Phase(int val) {
        alEffecti(id, AL_FLANGER_PHASE, cast(ALint)val);
    }

    @property float Rate() {
        ALfloat val;
        alGetEffectf(id, AL_FLANGER_RATE, &val);
        return val;
    }

    @property void Rate(ALfloat val) {
        alEffectf(id, AL_FLANGER_RATE, val);
    }

    @property float Depth() {
        ALfloat val;
        alGetEffectf(id, AL_FLANGER_DEPTH, &val);
        return val;
    }

    @property void Depth(ALfloat val) {
        alEffectf(id, AL_FLANGER_DEPTH, val);
    }

    @property float Feedback() {
        ALfloat val;
        alGetEffectf(id, AL_FLANGER_FEEDBACK, &val);
        return val;
    }

    @property void Feedback(ALfloat val) {
        alEffectf(id, AL_FLANGER_FEEDBACK, val);
    }

    @property float Delay() {
        ALfloat val;
        alGetEffectf(id, AL_FLANGER_DELAY, &val);
        return val;
    }

    @property void Delay(ALfloat val) {
        alEffectf(id, AL_FLANGER_DELAY, val);
    }
}