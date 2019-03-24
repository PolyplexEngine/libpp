module polyplex.core.audio.effects.reverb;
import polyplex.core.audio.effect;
import openal;

public class ReverbEffect : AudioEffect {
public:
    this() {
        super(EffectType.Reverb);
        setupDone();
    }

    @property float Decay() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_DECAY_TIME, &val);
        return val;
    }

    @property void Decay(ALfloat val) {
        alEffectf(id, AL_REVERB_DECAY_TIME, val);
    }

    @property float DecayHighFreqRatio() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_DECAY_HFRATIO, &val);
        return val;
    }

    @property void DecayHighFreqRatio(ALfloat val) {
        alEffectf(id, AL_REVERB_DECAY_HFRATIO, val);
    }

    @property float Density() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_DENSITY, &val);
        return val;
    }

    @property void Density(ALfloat val) {
        alEffectf(id, AL_REVERB_DENSITY, val);
    }

    @property float Diffusion() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_DIFFUSION, &val);
        return val;
    }

    @property void Diffusion(ALfloat val) {
        alEffectf(id, AL_REVERB_DIFFUSION, val);
    }

    @property float Gain() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_GAIN, &val);
        return val;
    }

    @property void Gain(ALfloat val) {
        alEffectf(id, AL_REVERB_GAIN, val);
    }

    @property float GainHighFreq() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_GAINHF, &val);
        return val;
    }

    @property void GainHighFreq(ALfloat val) {
        alEffectf(id, AL_REVERB_GAINHF, val);
    }

    @property float ReflectionsGain() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_REFLECTIONS_GAIN, &val);
        return val;
    }

    @property void ReflectionsGain(ALfloat val) {
        alEffectf(id, AL_REVERB_REFLECTIONS_GAIN, val);
    }

    @property float ReflectionsDelay() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_REFLECTIONS_DELAY, &val);
        return val;
    }

    @property void ReflectionsDelay(ALfloat val) {
        alEffectf(id, AL_REVERB_REFLECTIONS_DELAY, val);
    }

    @property float LateReverbGain() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_LATE_REVERB_GAIN, &val);
        return val;
    }

    @property void LateReverbGain(ALfloat val) {
        alEffectf(id, AL_REVERB_LATE_REVERB_GAIN, val);
    }

    @property float LateReverbDelay() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_LATE_REVERB_DELAY, &val);
        return val;
    }

    @property void LateReverbDelay(ALfloat val) {
        alEffectf(id, AL_REVERB_LATE_REVERB_DELAY, val);
    }

    @property float AirAbsorbtionGainHighFreq() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_AIR_ABSORPTION_GAINHF, &val);
        return val;
    }

    @property void AirAbsorbtionGainHighFreq(ALfloat val) {
        alEffectf(id, AL_REVERB_AIR_ABSORPTION_GAINHF, val);
    }

    @property float RoomRollOffFactor() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_ROOM_ROLLOFF_FACTOR, &val);
        return val;
    }

    @property void RoomRollOffFactor(ALfloat val) {
        alEffectf(id, AL_REVERB_ROOM_ROLLOFF_FACTOR, val);
    }

    @property float DecayHighFreqLimit() {
        ALfloat val;
        alGetEffectf(id, AL_REVERB_DECAY_HFLIMIT, &val);
        return val;
    }

    @property void DecayHighFreqLimit(ALfloat val) {
        alEffectf(id, AL_REVERB_DECAY_HFLIMIT, val);
    }
}