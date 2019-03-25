module audio.effects.eaxreverb;
import audio.effects;
import audio.effect;
import openal;

/*
    An advanced form of reverb which also supports echoing
    WARNING: Some sound cards might not support this.

    If in doubt you can bundle OpenAL-soft with the application.
    OpenAL-Soft has no hardware accelleration but supports AL_EFFECT_EAXREVERB.
*/
public class RoomDynamicsEffect : AudioEffect {
public:
    this() {
        super(EffectType.RoomDynamics);
        setupDone();
    }

    @property float Decay() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DECAY_TIME, &val);
        return val;
    }

    @property void Decay(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DECAY_TIME, val);
    }

    @property float DecayHighFreqRatio() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DECAY_HFRATIO, &val);
        return val;
    }

    @property void DecayHighFreqRatio(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DECAY_HFRATIO, val);
    }

    @property float DecayLowFreqRatio() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DECAY_LFRATIO, &val);
        return val;
    }

    @property void DecayLowFreqRatio(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DECAY_LFRATIO, val);
    }

    @property float Density() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DENSITY, &val);
        return val;
    }

    @property void Density(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DENSITY, val);
    }

    @property float Diffusion() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DIFFUSION, &val);
        return val;
    }

    @property void Diffusion(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DIFFUSION, val);
    }

    @property float Gain() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_GAIN, &val);
        return val;
    }

    @property void Gain(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_GAIN, val);
    }

    @property float GainHighFreq() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_GAINHF, &val);
        return val;
    }

    @property void GainHighFreq(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_GAINHF, val);
    }

    @property float GainLowFreq() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_GAINLF, &val);
        return val;
    }

    @property void GainLowFreq(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_GAINLF, val);
    }

    @property float ReflectionsGain() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_REFLECTIONS_GAIN, &val);
        return val;
    }

    @property void ReflectionsGain(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_REFLECTIONS_GAIN, val);
    }

    @property float ReflectionsDelay() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_REFLECTIONS_DELAY, &val);
        return val;
    }

    @property void ReflectionsDelay(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_REFLECTIONS_DELAY, val);
    }

    @property float ReflectionsPan() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_REFLECTIONS_PAN, &val);
        return val;
    }

    @property void ReflectionsPan(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_REFLECTIONS_PAN, val);
    }

    @property float EchoTime() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_ECHO_TIME, &val);
        return val;
    }

    @property void EchoTime(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_ECHO_TIME, val);
    }

    @property float EchoDepth() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_ECHO_DEPTH, &val);
        return val;
    }

    @property void EchoDepth(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_ECHO_DEPTH, val);
    }

    @property float ModulationTime() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_MODULATION_TIME, &val);
        return val;
    }

    @property void ModulationTime(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_MODULATION_TIME, val);
    }

    @property float ModulationDepth() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_MODULATION_DEPTH, &val);
        return val;
    }

    @property void ModulationDepth(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_MODULATION_DEPTH, val);
    }

    @property float LateReverbGain() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_LATE_REVERB_GAIN, &val);
        return val;
    }

    @property void LateReverbGain(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_LATE_REVERB_GAIN, val);
    }

    @property float LateReverbDelay() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_LATE_REVERB_DELAY, &val);
        return val;
    }

    @property void LateReverbDelay(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_LATE_REVERB_DELAY, val);
    }

    @property float AirAbsorbtionGainHighFreq() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_AIR_ABSORPTION_GAINHF, &val);
        return val;
    }

    @property void AirAbsorbtionGainHighFreq(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_AIR_ABSORPTION_GAINHF, val);
    }

    @property float RoomRollOffFactor() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_ROOM_ROLLOFF_FACTOR, &val);
        return val;
    }

    @property void RoomRollOffFactor(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_ROOM_ROLLOFF_FACTOR, val);
    }

    @property float HighFreqReference() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_HFREFERENCE, &val);
        return val;
    }

    @property void HighFreqReference(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_HFREFERENCE, val);
    }

    @property float LowFreqReference() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_LFREFERENCE, &val);
        return val;
    }

    @property void LowFreqReference(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_LFREFERENCE, val);
    }

    @property float DecayHighFreqLimit() {
        ALfloat val;
        alGetEffectf(id, AL_EAXREVERB_DECAY_HFLIMIT, &val);
        return val;
    }

    @property void DecayHighFreqLimit(ALfloat val) {
        alEffectf(id, AL_EAXREVERB_DECAY_HFLIMIT, val);
    }
}