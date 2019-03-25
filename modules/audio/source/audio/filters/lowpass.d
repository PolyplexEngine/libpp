module audio.filters.lowpass;
import audio.effect;
import openal;

// TODO: Implement high pass filter

public class LowpassFilter : AudioFilter {
public:
    this() {
        super(FilterType.Lowpass);
    }

    @property float Gain() {
        return GainBase;
    }

    @property void Gain(ALfloat val) {
        GainBase = val;
        GainHF = val;
    }

    @property float GainBase() {
        ALfloat val;
        alGetFilterf(id, AL_LOWPASS_GAIN, &val);
        return val;
    }

    @property void GainBase(ALfloat val) {
        alFilterf(id, AL_LOWPASS_GAIN, val);
    }

    @property float GainHF() {
        ALfloat val;
        alGetFilterf(id, AL_LOWPASS_GAINHF, &val);
        return val;
    }

    @property void GainHF(ALfloat val) {
        alFilterf(id, AL_LOWPASS_GAINHF, val);
    }
}