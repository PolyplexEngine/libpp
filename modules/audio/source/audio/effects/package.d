module audio.effects;

// Room simulation
public import audio.effects.eaxreverb;
public import audio.effects.reverb;
public import audio.effects.echo;

// Auto wah
public import audio.effects.autowah;

// Distortion causing effects
public import audio.effects.ringmod;
public import audio.effects.distortion;

// Frequency & pitch changers
public import audio.effects.freqshifter;
public import audio.effects.pitchshifter;
public import audio.effects.vocalmorph;

// Chorus and Flanger
public import audio.effects.chorus;
public import audio.effects.flanger;

// Mixing/Mastering
public import audio.effects.autocomp;
public import audio.effects.eq;

import openal;

enum WaveformType : ALenum {
    /// A sine wave form
    Sinusoid = AL_WAVEFORM_SINUSOID,

    /// A triangle wave form
    Triangle = AL_WAVEFORM_TRIANGLE,

    /// A saw wave form
    Saw = AL_WAVEFORM_SAW
}