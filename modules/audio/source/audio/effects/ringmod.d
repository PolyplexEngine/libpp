module audio.effects.ringmod;
import audio.effects;
import audio.effect;
import openal;

/// A ring modulator
public class RingModEffect : AudioEffect {
public:
    this() {
        super(EffectType.RingModulation);
        setupDone();
    }

    @property float Frequency() {
        ALfloat val;
        alGetEffectf(id, AL_RING_MODULATOR_FREQUENCY, &val);
        return val;
    }

    @property void Frequency(ALfloat val) {
        alEffectf(id, AL_RING_MODULATOR_FREQUENCY, val);
    }

    @property float HighpassCutoff() {
        ALfloat val;
        alGetEffectf(id, AL_RING_MODULATOR_HIGHPASS_CUTOFF, &val);
        return val;
    }

    @property void HighpassCutoff(ALfloat val) {
        alEffectf(id, AL_RING_MODULATOR_HIGHPASS_CUTOFF, val);
    }

    @property WaveformType Waveform() {
        ALenum val;
        alGetEffecti(id, AL_RING_MODULATOR_WAVEFORM, &val);
        return cast(WaveformType)val;
    }

    @property void Waveform(WaveformType val) {
        alEffecti(id, AL_RING_MODULATOR_WAVEFORM, cast(ALuint)val);
    }
}