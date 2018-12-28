module polyplex.core.audio.effects.pitchshifter;
import polyplex.core.audio.effects;
import polyplex.core.audio.effect;
import openal;

/// A frequency shifter
public class PitchShifterEffect : AudioEffect {
public:
    this() {
        super(EffectType.PitchShifter);
        setupDone();
    }

    @property float CourseTune() {
        ALfloat val;
        alGetEffectf(id, AL_PITCH_SHIFTER_COARSE_TUNE, &val);
        return val;
    }

    @property void CourseTune(ALfloat val) {
        alEffectf(id, AL_PITCH_SHIFTER_COARSE_TUNE, val);
    }

    @property float FineTune() {
        ALfloat val;
        alGetEffectf(id, AL_PITCH_SHIFTER_FINE_TUNE, &val);
        return val;
    }

    @property void FineTune(ALfloat val) {
        alEffectf(id, AL_PITCH_SHIFTER_FINE_TUNE, val);
    }
}