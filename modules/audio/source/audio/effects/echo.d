module audio.effects.echo;
import audio.effects;
import audio.effect;
import openal;

/// An Echo
public class EchoEffect : AudioEffect {
public:
    this() {
        super(EffectType.Echo);
        setupDone();
    }

    @property float Delay() {
        ALfloat val;
        alGetEffectf(id, AL_ECHO_DELAY, &val);
        return val;
    }

    @property void Delay(ALfloat val) {
        alEffectf(id, AL_ECHO_DELAY, val);
    }

    @property float LRDelay() {
        ALfloat val;
        alGetEffectf(id, AL_ECHO_LRDELAY, &val);
        return val;
    }

    @property void LRDelay(ALfloat val) {
        alEffectf(id, AL_ECHO_LRDELAY, val);
    }

    @property float Damping() {
        ALfloat val;
        alGetEffectf(id, AL_ECHO_DAMPING, &val);
        return val;
    }

    @property void Damping(ALfloat val) {
        alEffectf(id, AL_ECHO_DAMPING, val);
    }

    @property float Feedback() {
        ALfloat val;
        alGetEffectf(id, AL_ECHO_FEEDBACK, &val);
        return val;
    }

    @property void Feedback(ALfloat val) {
        alEffectf(id, AL_ECHO_FEEDBACK, val);
    }

    @property float Spread() {
        ALfloat val;
        alGetEffectf(id, AL_ECHO_SPREAD, &val);
        return val;
    }

    @property void Spread(ALfloat val) {
        alEffectf(id, AL_ECHO_SPREAD, val);
    }
}