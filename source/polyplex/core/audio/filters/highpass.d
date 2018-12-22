module polyplex.core.audio.filters.highpass;
import polyplex.core.audio.effect;
import openal;

// TODO: Implement high pass filter

public class HighpassFilter : AudioFilter {
public:
    this() {
        super(FilterType.Highpass);
    }

    @property float FilterGain() {
        ALfloat val;
        alGetFilterf(id, AL_HIGHPASS_GAIN, &val);
        return val;
    }

    @property void FilterGain(ALfloat val) {
        alFilterf(id, AL_HIGHPASS_GAIN, val);
    }

    @property float Gain() {
        ALfloat val;
        alGetFilterf(id, AL_HIGHPASS_GAINLF, &val);
        return val;
    }

    @property void Gain(ALfloat val) {
        alFilterf(id, AL_HIGHPASS_GAINLF, val);
    }
}