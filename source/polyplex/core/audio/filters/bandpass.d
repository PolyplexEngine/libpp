module polyplex.core.audio.filters.bandpass;
import polyplex.core.audio.effect;
import openal;

// TODO: Implement high pass filter

public class BandpassFilter : AudioFilter {
public:
    this() {
        super(FilterType.Bandpass);
    }

    @property float FilterGain() {
        ALfloat val;
        alGetFilterf(id, AL_BANDPASS_GAIN, &val);
        return val;
    }

    @property void FilterGain(ALfloat val) {
        alFilterf(id, AL_BANDPASS_GAIN, val);
    }

    @property float GainLow() {
        ALfloat val;
        alGetFilterf(id, AL_BANDPASS_GAINLF, &val);
        return val;
    }

    @property void GainLow(ALfloat val) {
        alFilterf(id, AL_BANDPASS_GAINLF, val);
    }

    @property float GainHigh() {
        ALfloat val;
        alGetFilterf(id, AL_BANDPASS_GAINHF, &val);
        return val;
    }

    @property void GainHigh(ALfloat val) {
        alFilterf(id, AL_BANDPASS_GAINHF, val);
    }
}