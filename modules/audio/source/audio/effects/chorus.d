module audio.effects.chorus;
import audio.effects;
import audio.effect;
import openal;

/// A Chours
public class ChorusEffect : AudioEffect {
public:
    this() {
        super(EffectType.Chorus);
        setupDone();
    }

    @property WaveformType Waveform() {
        ALenum val;
        alGetEffecti(id, AL_CHORUS_WAVEFORM, &val);
        return cast(WaveformType)val;
    }

    @property void Waveform(WaveformType val) {
        alEffecti(id, AL_CHORUS_WAVEFORM, cast(ALuint)val);
    }

    @property int Phase() {
        ALint val;
        alGetEffecti(id, AL_CHORUS_PHASE, &val);
        return cast(int)val;
    }

    @property void Phase(int val) {
        alEffecti(id, AL_CHORUS_PHASE, cast(ALint)val);
    }

    @property float Rate() {
        ALfloat val;
        alGetEffectf(id, AL_CHORUS_RATE, &val);
        return val;
    }

    @property void Rate(ALfloat val) {
        alEffectf(id, AL_CHORUS_RATE, val);
    }

    @property float Depth() {
        ALfloat val;
        alGetEffectf(id, AL_CHORUS_DEPTH, &val);
        return val;
    }

    @property void Depth(ALfloat val) {
        alEffectf(id, AL_CHORUS_DEPTH, val);
    }

    @property float Feedback() {
        ALfloat val;
        alGetEffectf(id, AL_CHORUS_FEEDBACK, &val);
        return val;
    }

    @property void Feedback(ALfloat val) {
        alEffectf(id, AL_CHORUS_FEEDBACK, val);
    }

    @property float Delay() {
        ALfloat val;
        alGetEffectf(id, AL_CHORUS_DELAY, &val);
        return val;
    }

    @property void Delay(ALfloat val) {
        alEffectf(id, AL_CHORUS_DELAY, val);
    }
}