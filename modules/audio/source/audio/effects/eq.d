module audio.effects.eq;
import audio.effects;
import audio.effect;
import openal;

/// An equalizer.
public class EqualizerEffect : AudioEffect {
public:
    this() {
        super(EffectType.Equalizer);
        setupDone();
    }

    // LOW

    @property float LowGain() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_LOW_GAIN, &val);
        return val;
    }

    @property void LowGain(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_LOW_GAIN, val);
    }

    @property float LowCutoff() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_LOW_CUTOFF, &val);
        return val;
    }

    @property void LowCutoff(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_LOW_CUTOFF, val);
    }

    // MID 1

    @property float Mid1Gain() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID1_GAIN, &val);
        return val;
    }

    @property void Mid1Gain(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID1_GAIN, val);
    }

    @property float Mid1Center() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID1_CENTER, &val);
        return val;
    }

    @property void Mid1Center(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID1_CENTER, val);
    }

    @property float Mid1Width() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID1_WIDTH, &val);
        return val;
    }

    @property void Mid1Width(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID1_WIDTH, val);
    }

    // MID 2

    @property float Mid2Gain() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID2_GAIN, &val);
        return val;
    }

    @property void Mid2Gain(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID2_GAIN, val);
    }

    @property float Mid2Center() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID2_CENTER, &val);
        return val;
    }

    @property void Mid2Center(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID2_CENTER, val);
    }

    @property float Mid2Width() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_MID2_WIDTH, &val);
        return val;
    }

    @property void Mid2Width(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_MID2_WIDTH, val);
    }

    // HIGH

    @property float HighGain() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_HIGH_GAIN, &val);
        return val;
    }

    @property void HighGain(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_HIGH_GAIN, val);
    }

    @property float HighCutoff() {
        ALfloat val;
        alGetEffectf(id, AL_EQUALIZER_HIGH_CUTOFF, &val);
        return val;
    }

    @property void HighCutoff(ALfloat val) {
        alEffectf(id, AL_EQUALIZER_HIGH_CUTOFF, val);
    }
}