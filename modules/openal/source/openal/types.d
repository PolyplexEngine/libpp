// Taken from Derelict-AL
module openal.types;

// al
enum AL_VERSION_1_0 = true;
enum AL_VERSION_1_1 = true;

alias ALboolean = byte;
alias ALchar = char;
alias ALbyte = byte;
alias ALubyte = ubyte;
alias ALshort = short;
alias ALushort = ushort;
alias ALint = int;
alias ALuint = uint;
alias ALsizei = int;
alias ALenum = int;
alias ALfloat = float;
alias ALdouble = double;
alias ALvoid = void;

enum : ALboolean {
    AL_FALSE               = 0,
    AL_TRUE                = 1,
}

enum : ALenum {
    AL_INVALID              = -1,
    AL_NONE                 = 0,

    AL_SOURCE_RELATIVE      = 0x202,

    AL_CONE_INNER_ANGLE     = 0x1001,
    AL_CONE_OUTER_ANGLE     = 0x1002,

    AL_PITCH                = 0x1003,
    AL_POSITION             = 0x1004,
    AL_DIRECTION            = 0x1005,
    AL_VELOCITY             = 0x1006,
    AL_LOOPING              = 0x1007,
    AL_BUFFER               = 0x1009,
    AL_GAIN                 = 0x100A,
    AL_MIN_GAIN             = 0x100D,
    AL_MAX_GAIN             = 0x100E,
    AL_ORIENTATION          = 0x100F,

    AL_CHANNEL_MASK         = 0x3000,

    AL_SOURCE_STATE         = 0x1010,
    AL_INITIAL              = 0x1011,
    AL_PLAYING              = 0x1012,
    AL_PAUSED               = 0x1013,
    AL_STOPPED              = 0x1014,

    AL_BUFFERS_QUEUED       = 0x1015,
    AL_BUFFERS_PROCESSED    = 0x1016,

    AL_REFERENCE_DISTANCE   = 0x1020,
    AL_ROLLOFF_FACTOR       = 0x1021,
    AL_CONE_OUTER_GAIN      = 0x1022,
    AL_MAX_DISTANCE         = 0x1023,

    AL_SEC_OFFSET           = 0x1024,
    AL_SAMPLE_OFFSET        = 0x1025,
    AL_BYTE_OFFSET          = 0x1026,

    AL_SOURCE_TYPE          = 0x1027,
    AL_STATIC               = 0x1028,
    AL_STREAMING            = 0x1029,
    AL_UNDETERMINED         = 0x1030,

    AL_FORMAT_MONO8         = 0x1100,
    AL_FORMAT_MONO16        = 0x1101,
    AL_FORMAT_STEREO8       = 0x1102,
    AL_FORMAT_STEREO16      = 0x1103,

    AL_FREQUENCY            = 0x2001,
    AL_BITS                 = 0x2002,
    AL_CHANNELS             = 0x2003,
    AL_SIZE                 = 0x2004,

    AL_UNUSED               = 0x2010,
    AL_PENDING              = 0x2011,
    AL_PROCESSED            = 0x2012,

    AL_NO_ERROR             = AL_FALSE,

    AL_INVALID_NAME         = 0xA001,
    AL_INVALID_ENUM         = 0xA002,
    AL_INVALID_VALUE        = 0xA003,
    AL_INVALID_OPERATION    = 0xA004,
    AL_OUT_OF_MEMORY        = 0xA005,

    AL_VENDOR               = 0xB001,
    AL_VERSION              = 0xB002,
    AL_RENDERER             = 0xB003,
    AL_EXTENSIONS           = 0xB004,

    AL_DOPPLER_FACTOR       = 0xC000,
    AL_DOPPLER_VELOCITY     = 0xC001,
    AL_SPEED_OF_SOUND       = 0xC003,

    AL_DISTANCE_MODEL               = 0xD000,
    AL_INVERSE_DISTANCE             = 0xD001,
    AL_INVERSE_DISTANCE_CLAMPED     = 0xD002,
    AL_LINEAR_DISTANCE              = 0xD003,
    AL_LINEAR_DISTANCE_CLAMPED      = 0xD004,
    AL_EXPONENT_DISTANCE            = 0xD005,
    AL_EXPONENT_DISTANCE_CLAMPED    = 0xD006,
}

// alc
enum ALC_VERSION_0_1 = true;

alias ALCdevice = void;
alias ALCcontext = void;

alias ALCboolean = byte;
alias ALCchar = char;
alias ALCbyte = byte;
alias ALCubyte = ubyte;
alias ALCshort = short;
alias ALCushort = ushort;
alias ALCint = int;
alias ALCuint = uint;
alias ALCsizei = int;
alias ALCenum = int;
alias ALCfloat = float;
alias ALCdouble = double;
alias ALCvoid = void;

enum : ALCboolean {
    ALC_FALSE           = 0,
    ALC_TRUE            = 1,
}

enum : ALCenum {
    ALC_FREQUENCY           = 0x1007,
    ALC_REFRESH             = 0x1008,
    ALC_SYNC                = 0x1009,

    ALC_MONO_SOURCES        = 0x1010,
    ALC_STEREO_SOURCES      = 0x1011,

    ALC_NO_ERROR            = ALC_FALSE,
    ALC_INVALID_DEVICE      = 0xA001,
    ALC_INVALID_CONTEXT     = 0xA002,
    ALC_INVALID_ENUM        = 0xA003,
    ALC_INVALID_VALUE       = 0xA004,
    ALC_OUT_OF_MEMORY       = 0xA005,

    ALC_DEFAULT_DEVICE_SPECIFIER        = 0x1004,
    ALC_DEVICE_SPECIFIER                = 0x1005,
    ALC_EXTENSIONS                      = 0x1006,

    ALC_MAJOR_VERSION                   = 0x1000,
    ALC_MINOR_VERSION                   = 0x1001,

    ALC_ATTRIBUTES_SIZE                 = 0x1002,
    ALC_ALL_ATTRIBUTES                  = 0x1003,

    ALC_CAPTURE_DEVICE_SPECIFIER            = 0x310,
    ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER    = 0x311,
    ALC_CAPTURE_SAMPLES                     = 0x312,
}

// alext
enum : ALenum {
    // AL_LOKI_IMA_ADPCM_format
    AL_FORMAT_IMA_ADPCM_MONO16_EXT          = 0x10000,
    AL_FORMAT_IMA_ADPCM_STEREO16_EXT        = 0x10001,

    // AL_LOKI_WAVE_format
    AL_FORMAT_WAVE_EXT                      = 0x10002,

    // AL_EXT_vorbis
    AL_FORMAT_VORBIS_EXT                    = 0x10003,

    // AL_LOKI_quadriphonic
    AL_FORMAT_QUAD8_LOKI                    = 0x10004,
    AL_FORMAT_QUAD16_LOKI                   = 0x10005,

    // AL_EXT_float32
    AL_FORMAT_MONO_FLOAT32                  = 0x10010,
    AL_FORMAT_STEREO_FLOAT32                = 0x10011,

    // ALC_LOKI_audio_channel
    ALC_CHAN_MAIN_LOKI                      = 0x500001,
    ALC_CHAN_PCM_LOKI                       = 0x500002,
    ALC_CHAN_CD_LOKI                        = 0x500003,

    // ALC_ENUMERATE_ALL_EXT
    ALC_DEFAULT_ALL_DEVICES_SPECIFIER       = 0x1012,
    ALC_ALL_DEVICES_SPECIFIER               = 0x1013,

    // AL_EXT_MCFORMATS
    AL_FORMAT_QUAD8                         = 0x1204,
    AL_FORMAT_QUAD16                        = 0x1205,
    AL_FORMAT_QUAD32                        = 0x1206,
    AL_FORMAT_REAR8                         = 0x1207,
    AL_FORMAT_REAR16                        = 0x1208,
    AL_FORMAT_REAR32                        = 0x1209,
    AL_FORMAT_51CHN8                        = 0x120A,
    AL_FORMAT_51CHN16                       = 0x120B,
    AL_FORMAT_51CHN32                       = 0x120C,
    AL_FORMAT_61CHN8                        = 0x120D,
    AL_FORMAT_61CHN16                       = 0x120E,
    AL_FORMAT_61CHN32                       = 0x120F,
    AL_FORMAT_71CHN8                        = 0x1210,
    AL_FORMAT_71CHN16                       = 0x1211,
    AL_FORMAT_71CHN32                       = 0x1212,

    // AL_EXT_IMA4
    AL_FORMAT_MONO_IMA4                     = 0x1300,
    AL_FORMAT_STEREO_IMA4                   = 0x1301,
}

enum : ALenum {
    ALC_EFX_MAJOR_VERSION                   = 0x20001,
    ALC_EFX_MINOR_VERSION                   = 0x20002,
    ALC_MAX_AUXILIARY_SENDS                 = 0x20003,


    /* Listener properties. */
    AL_METERS_PER_UNIT                      = 0x20004,

    /* Source properties. */
    AL_DIRECT_FILTER                        = 0x20005,
    AL_AUXILIARY_SEND_FILTER                = 0x20006,
    AL_AIR_ABSORPTION_FACTOR                = 0x20007,
    AL_ROOM_ROLLOFF_FACTOR                  = 0x20008,
    AL_CONE_OUTER_GAINHF                    = 0x20009,
    AL_DIRECT_FILTER_GAINHF_AUTO            = 0x2000A,
    AL_AUXILIARY_SEND_FILTER_GAIN_AUTO      = 0x2000B,
    AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO    = 0x2000C,


    /* Effect properties. */

    /* Reverb effect parameters */
    AL_REVERB_DENSITY                       = 0x0001,
    AL_REVERB_DIFFUSION                     = 0x0002,
    AL_REVERB_GAIN                          = 0x0003,
    AL_REVERB_GAINHF                        = 0x0004,
    AL_REVERB_DECAY_TIME                    = 0x0005,
    AL_REVERB_DECAY_HFRATIO                 = 0x0006,
    AL_REVERB_REFLECTIONS_GAIN              = 0x0007,
    AL_REVERB_REFLECTIONS_DELAY             = 0x0008,
    AL_REVERB_LATE_REVERB_GAIN              = 0x0009,
    AL_REVERB_LATE_REVERB_DELAY             = 0x000A,
    AL_REVERB_AIR_ABSORPTION_GAINHF         = 0x000B,
    AL_REVERB_ROOM_ROLLOFF_FACTOR           = 0x000C,
    AL_REVERB_DECAY_HFLIMIT                 = 0x000D,

    /* EAX Reverb effect parameters */
    AL_EAXREVERB_DENSITY                    = 0x0001,
    AL_EAXREVERB_DIFFUSION                  = 0x0002,
    AL_EAXREVERB_GAIN                       = 0x0003,
    AL_EAXREVERB_GAINHF                     = 0x0004,
    AL_EAXREVERB_GAINLF                     = 0x0005,
    AL_EAXREVERB_DECAY_TIME                 = 0x0006,
    AL_EAXREVERB_DECAY_HFRATIO              = 0x0007,
    AL_EAXREVERB_DECAY_LFRATIO              = 0x0008,
    AL_EAXREVERB_REFLECTIONS_GAIN           = 0x0009,
    AL_EAXREVERB_REFLECTIONS_DELAY          = 0x000A,
    AL_EAXREVERB_REFLECTIONS_PAN            = 0x000B,
    AL_EAXREVERB_LATE_REVERB_GAIN           = 0x000C,
    AL_EAXREVERB_LATE_REVERB_DELAY          = 0x000D,
    AL_EAXREVERB_LATE_REVERB_PAN            = 0x000E,
    AL_EAXREVERB_ECHO_TIME                  = 0x000F,
    AL_EAXREVERB_ECHO_DEPTH                 = 0x0010,
    AL_EAXREVERB_MODULATION_TIME            = 0x0011,
    AL_EAXREVERB_MODULATION_DEPTH           = 0x0012,
    AL_EAXREVERB_AIR_ABSORPTION_GAINHF      = 0x0013,
    AL_EAXREVERB_HFREFERENCE                = 0x0014,
    AL_EAXREVERB_LFREFERENCE                = 0x0015,
    AL_EAXREVERB_ROOM_ROLLOFF_FACTOR        = 0x0016,
    AL_EAXREVERB_DECAY_HFLIMIT              = 0x0017,

    /* Chorus effect parameters */
    AL_CHORUS_WAVEFORM                      = 0x0001,
    AL_CHORUS_PHASE                         = 0x0002,
    AL_CHORUS_RATE                          = 0x0003,
    AL_CHORUS_DEPTH                         = 0x0004,
    AL_CHORUS_FEEDBACK                      = 0x0005,
    AL_CHORUS_DELAY                         = 0x0006,

    /* Distortion effect parameters */
    AL_DISTORTION_EDGE                      = 0x0001,
    AL_DISTORTION_GAIN                      = 0x0002,
    AL_DISTORTION_LOWPASS_CUTOFF            = 0x0003,
    AL_DISTORTION_EQCENTER                  = 0x0004,
    AL_DISTORTION_EQBANDWIDTH               = 0x0005,

    /* Echo effect parameters */
    AL_ECHO_DELAY                           = 0x0001,
    AL_ECHO_LRDELAY                         = 0x0002,
    AL_ECHO_DAMPING                         = 0x0003,
    AL_ECHO_FEEDBACK                        = 0x0004,
    AL_ECHO_SPREAD                          = 0x0005,

    /* Flanger effect parameters */
    AL_FLANGER_WAVEFORM                     = 0x0001,
    AL_FLANGER_PHASE                        = 0x0002,
    AL_FLANGER_RATE                         = 0x0003,
    AL_FLANGER_DEPTH                        = 0x0004,
    AL_FLANGER_FEEDBACK                     = 0x0005,
    AL_FLANGER_DELAY                        = 0x0006,

    /* Frequency shifter effect parameters */
    AL_FREQUENCY_SHIFTER_FREQUENCY          = 0x0001,
    AL_FREQUENCY_SHIFTER_LEFT_DIRECTION     = 0x0002,
    AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION    = 0x0003,

    /* Vocal morpher effect parameters */
    AL_VOCAL_MORPHER_PHONEMEA               = 0x0001,
    AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING = 0x0002,
    AL_VOCAL_MORPHER_PHONEMEB               = 0x0003,
    AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING = 0x0004,
    AL_VOCAL_MORPHER_WAVEFORM               = 0x0005,
    AL_VOCAL_MORPHER_RATE                   = 0x0006,

    /* Pitchshifter effect parameters */
    AL_PITCH_SHIFTER_COARSE_TUNE            = 0x0001,
    AL_PITCH_SHIFTER_FINE_TUNE              = 0x0002,

    /* Ringmodulator effect parameters */
    AL_RING_MODULATOR_FREQUENCY             = 0x0001,
    AL_RING_MODULATOR_HIGHPASS_CUTOFF       = 0x0002,
    AL_RING_MODULATOR_WAVEFORM              = 0x0003,

    /* Autowah effect parameters */
    AL_AUTOWAH_ATTACK_TIME                  = 0x0001,
    AL_AUTOWAH_RELEASE_TIME                 = 0x0002,
    AL_AUTOWAH_RESONANCE                    = 0x0003,
    AL_AUTOWAH_PEAK_GAIN                    = 0x0004,

    /* Compressor effect parameters */
    AL_COMPRESSOR_ONOFF                     = 0x0001,

    /* Equalizer effect parameters */
    AL_EQUALIZER_LOW_GAIN                   = 0x0001,
    AL_EQUALIZER_LOW_CUTOFF                 = 0x0002,
    AL_EQUALIZER_MID1_GAIN                  = 0x0003,
    AL_EQUALIZER_MID1_CENTER                = 0x0004,
    AL_EQUALIZER_MID1_WIDTH                 = 0x0005,
    AL_EQUALIZER_MID2_GAIN                  = 0x0006,
    AL_EQUALIZER_MID2_CENTER                = 0x0007,
    AL_EQUALIZER_MID2_WIDTH                 = 0x0008,
    AL_EQUALIZER_HIGH_GAIN                  = 0x0009,
    AL_EQUALIZER_HIGH_CUTOFF                = 0x000A,

    /* Effect type */
    AL_EFFECT_FIRST_PARAMETER               = 0x0000,
    AL_EFFECT_LAST_PARAMETER                = 0x8000,
    AL_EFFECT_TYPE                          = 0x8001,

    /* Effect types, used with the AL_EFFECT_TYPE property */
    AL_EFFECT_NULL                          = 0x0000,
    AL_EFFECT_REVERB                        = 0x0001,
    AL_EFFECT_CHORUS                        = 0x0002,
    AL_EFFECT_DISTORTION                    = 0x0003,
    AL_EFFECT_ECHO                          = 0x0004,
    AL_EFFECT_FLANGER                       = 0x0005,
    AL_EFFECT_FREQUENCY_SHIFTER             = 0x0006,
    AL_EFFECT_VOCAL_MORPHER                 = 0x0007,
    AL_EFFECT_PITCH_SHIFTER                 = 0x0008,
    AL_EFFECT_RING_MODULATOR                = 0x0009,
    AL_EFFECT_AUTOWAH                       = 0x000A,
    AL_EFFECT_COMPRESSOR                    = 0x000B,
    AL_EFFECT_EQUALIZER                     = 0x000C,
    AL_EFFECT_EAXREVERB                     = 0x8000,

    /* Auxiliary Effect Slot properties. */
    AL_EFFECTSLOT_EFFECT                    = 0x0001,
    AL_EFFECTSLOT_GAIN                      = 0x0002,
    AL_EFFECTSLOT_AUXILIARY_SEND_AUTO       = 0x0003,

    /* NULL Auxiliary Slot ID to disable a source send. */
    AL_EFFECTSLOT_NULL                      = 0x0000,


    /* Filter properties. */

    /* Lowpass filter parameters */
    AL_LOWPASS_GAIN                         = 0x0001,
    AL_LOWPASS_GAINHF                       = 0x0002,

    /* Highpass filter parameters */
    AL_HIGHPASS_GAIN                        = 0x0001,
    AL_HIGHPASS_GAINLF                      = 0x0002,

    /* Bandpass filter parameters */
    AL_BANDPASS_GAIN                        = 0x0001,
    AL_BANDPASS_GAINLF                      = 0x0002,
    AL_BANDPASS_GAINHF                      = 0x0003,

    /* Filter type */
    AL_FILTER_FIRST_PARAMETER               = 0x0000,
    AL_FILTER_LAST_PARAMETER                = 0x8000,
    AL_FILTER_TYPE                          = 0x8001,

    /* Filter types, used with the AL_FILTER_TYPE property */
    AL_FILTER_NULL                          = 0x0000,
    AL_FILTER_LOWPASS                       = 0x0001,
    AL_FILTER_HIGHPASS                      = 0x0002,
    AL_FILTER_BANDPASS                      = 0x0003
}