module polyplex.core.audio.effects;

// Room simulation
public import polyplex.core.audio.effects.eaxreverb;
public import polyplex.core.audio.effects.reverb;
public import polyplex.core.audio.effects.echo;

// Auto wah
public import polyplex.core.audio.effects.autowah;

// Distortion causing effects
public import polyplex.core.audio.effects.ringmod;
public import polyplex.core.audio.effects.distortion;

// Frequency & pitch changers
public import polyplex.core.audio.effects.freqshifter;
public import polyplex.core.audio.effects.pitchshifter;
public import polyplex.core.audio.effects.vocalmorph;

// Chorus and Flanger
public import polyplex.core.audio.effects.chorus;
public import polyplex.core.audio.effects.flanger;

// Mixing/Mastering
public import polyplex.core.audio.effects.autocomp;
public import polyplex.core.audio.effects.eq;

import openal;

enum WaveformType : ALenum {
    /// A sine wave form
    Sinusoid = AL_WAVEFORM_SINUSOID,

    /// A triangle wave form
    Triangle = AL_WAVEFORM_TRIANGLE,

    /// A saw wave form
    Saw = AL_WAVEFORM_SAW
}