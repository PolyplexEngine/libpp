module polyplex.core.audio.filters.highpass;
import polyplex.core.audio.effect;
import openal;

// TODO: Implement high pass filter

public class HighpassFilter : AudioFilter {
public:
    this() {
        super(FilterType.Highpass);
    }

    @property float Gain() {
        return GainBase;
    }

    @property void Gain(ALfloat val) {
        GainBase = val;
        GainLF = val;
    }

    @property float GainBase() {
        ALfloat val;
        alGetFilterf(id, AL_HIGHPASS_GAIN, &val);
        return val;
    }

    @property void GainBase(ALfloat val) {
        alFilterf(id, AL_HIGHPASS_GAIN, val);
    }

    @property float GainLF() {
        ALfloat val;
        alGetFilterf(id, AL_HIGHPASS_GAINLF, &val);
        return val;
    }

    @property void GainLF(ALfloat val) {
        alFilterf(id, AL_HIGHPASS_GAINLF, val);
    }
}