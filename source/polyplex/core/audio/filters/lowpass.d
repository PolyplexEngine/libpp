module polyplex.core.audio.filters.lowpass;
import polyplex.core.audio.effect;
import openal;

// TODO: Implement high pass filter

public class LowpassFilter : AudioFilter {
public:
    this() {
        super(FilterType.Lowpass);
    }

    @property float FilterGain() {
        ALfloat val;
        alGetFilterf(id, AL_LOWPASS_GAIN, &val);
        return val;
    }

    @property void FilterGain(ALfloat val) {
        alFilterf(id, AL_LOWPASS_GAIN, val);
    }

    @property float Gain() {
        ALfloat val;
        alGetFilterf(id, AL_LOWPASS_GAINHF, &val);
        return val;
    }

    @property void Gain(ALfloat val) {
        alFilterf(id, AL_LOWPASS_GAINHF, val);
    }
}