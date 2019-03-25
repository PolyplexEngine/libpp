module audio.effects.distortion;
import audio.effects;
import audio.effect;
import openal;

/// An Distortion
public class DistortionEffect : AudioEffect {
public:
    this() {
        super(EffectType.Distortion);
        setupDone();
    }

    @property float Edge() {
        ALfloat val;
        alGetEffectf(id, AL_DISTORTION_EDGE, &val);
        return val;
    }

    @property void Edge(ALfloat val) {
        alEffectf(id, AL_DISTORTION_EDGE, val);
    }

    @property float Gain() {
        ALfloat val;
        alGetEffectf(id, AL_DISTORTION_GAIN, &val);
        return val;
    }

    @property void Gain(ALfloat val) {
        alEffectf(id, AL_DISTORTION_GAIN, val);
    }

    @property float LowpassCutoff() {
        ALfloat val;
        alGetEffectf(id, AL_DISTORTION_LOWPASS_CUTOFF, &val);
        return val;
    }

    @property void LowpassCutoff(ALfloat val) {
        alEffectf(id, AL_DISTORTION_LOWPASS_CUTOFF, val);
    }

    @property float EQCenter() {
        ALfloat val;
        alGetEffectf(id, AL_DISTORTION_EQCENTER, &val);
        return val;
    }

    @property void EQCenter(ALfloat val) {
        alEffectf(id, AL_DISTORTION_EQCENTER, val);
    }

    @property float EQBandwidth() {
        ALfloat val;
        alGetEffectf(id, AL_DISTORTION_EQBANDWIDTH, &val);
        return val;
    }

    @property void EQBandwidth(ALfloat val) {
        alEffectf(id, AL_DISTORTION_EQBANDWIDTH, val);
    }
}