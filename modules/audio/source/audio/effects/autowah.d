module audio.effects.autowah;
import audio.effects;
import audio.effect;
import openal;

/**
    An autowah effect

    MIGHT NOT WORK WITH OPENAL-SOFT
*/
public class AutoWahEffect : AudioEffect {
public:
    this() {
        super(EffectType.AutoWah);
        setupDone();
    }

    @property float Attack() {
        ALfloat val;
        alGetEffectf(id, AL_AUTOWAH_ATTACK_TIME, &val);
        return val;
    }

    @property void Attack(ALfloat val) {
        alEffectf(id, AL_AUTOWAH_ATTACK_TIME, val);
    }

    @property float Release() {
        ALfloat val;
        alGetEffectf(id, AL_AUTOWAH_RELEASE_TIME, &val);
        return val;
    }

    @property void Release(ALfloat val) {
        alEffectf(id, AL_AUTOWAH_RELEASE_TIME, val);
    }

    @property float Resonance() {
        ALfloat val;
        alGetEffectf(id, AL_AUTOWAH_RESONANCE, &val);
        return val;
    }

    @property void Resonance(ALfloat val) {
        alEffectf(id, AL_AUTOWAH_RESONANCE, val);
    }

    @property float PeakGain() {
        ALfloat val;
        alGetEffectf(id, AL_AUTOWAH_PEAK_GAIN, &val);
        return val;
    }

    @property void PeakGain(ALfloat val) {
        alEffectf(id, AL_AUTOWAH_PEAK_GAIN, val);
    }
}