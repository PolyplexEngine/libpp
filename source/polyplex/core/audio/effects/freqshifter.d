module polyplex.core.audio.effects.freqshifter;
import polyplex.core.audio.effects;
import polyplex.core.audio.effect;
import openal;

enum FrequencyShiftDirection : ALenum {
    Down = 0,
    Up = 1,
    Off = 2
}

/**
    A frequency shifter

    MIGHT NOT WORK WITH OPENAL-SOFT
*/ 
public class FrequencyShifterEffect : AudioEffect {
public:
    this() {
        super(EffectType.FreqencyShifter);
        setupDone();
    }

    @property float Frequency() {
        ALfloat val;
        alGetEffectf(id, AL_FREQUENCY_SHIFTER_FREQUENCY, &val);
        return val;
    }

    @property void Frequency(ALfloat val) {
        alEffectf(id, AL_FREQUENCY_SHIFTER_FREQUENCY, val);
    }

    @property FrequencyShiftDirection RightDirection() {
        ALenum val;
        alGetEffecti(id, AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION, &val);
        return cast(FrequencyShiftDirection)val;
    }

    @property void RightDirection(FrequencyShiftDirection val) {
        alEffecti(id, AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION, cast(ALuint)val);
    }

    @property FrequencyShiftDirection LeftDirection() {
        ALenum val;
        alGetEffecti(id, AL_FREQUENCY_SHIFTER_LEFT_DIRECTION, &val);
        return cast(FrequencyShiftDirection)val;
    }

    @property void LeftDirection(FrequencyShiftDirection val) {
        alEffecti(id, AL_FREQUENCY_SHIFTER_LEFT_DIRECTION, cast(ALuint)val);
    }
}