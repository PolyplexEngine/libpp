/**
Boost Software License - Version 1.0 - August 17th, 2003

Copyright (c) 2018 Clipsey

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module openal.binding;
import openal.types;
import bindbc.loader;
import std.string;

extern(C) @nogc nothrow {
    alias alEnableFunc                  = void function(ALenum);
    alias alDisableFunc                 = void function(ALenum);
    alias alIsEnabledFunc               = ALboolean function(ALenum);
    alias alGetStringFunc               = const(ALchar)* function(ALenum);
    alias alGetBooleanvFunc             = void function(ALenum, ALboolean*);
    alias alGetIntegervFunc             = void function(ALenum, ALint*);
    alias alGetFloatvFunc               = void function(ALenum, ALfloat*);
    alias alGetDoublevFunc              = void function(ALenum, ALdouble*);
    alias alGetBooleanFunc              = ALboolean function(ALenum);
    alias alGetIntegerFunc              = ALint function(ALenum);
    alias alGetFloatFunc                = ALfloat function(ALenum);
    alias alGetDoubleFunc               = ALdouble function(ALenum);
    alias alGetErrorFunc                = ALenum function();
    alias alIsExtensionPresentFunc      = ALboolean function(const(char)*);
    alias alGetProcAddressFunc          = ALvoid* function(const(char)*);
    alias alGetEnumValueFunc            = ALenum function(const(char)*);
    alias alListenerfFunc               = void function(ALenum, ALfloat);
    alias alListener3fFunc              = void function(ALenum, ALfloat, ALfloat, ALfloat);
    alias alListenerfvFunc              = void function(ALenum, const(ALfloat)*);
    alias alListeneriFunc               = void function(ALenum, ALint);
    alias alListener3iFunc              = void function(ALenum, ALint, ALint, ALint);
    alias alListenerivFunc              = void function(ALenum, const(ALint)*);
    alias alGetListenerfFunc            = void function(ALenum, ALfloat*);
    alias alGetListener3fFunc           = void function(ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias alGetListenerfvFunc           = void function(ALenum, ALfloat*);
    alias alGetListeneriFunc            = void function(ALenum, ALint*);
    alias alGetListener3iFunc           = void function(ALenum, ALint*, ALint*, ALint*);
    alias alGetListenerivFunc           = void function(ALenum, ALint*);
    alias alGenSourcesFunc              = void function(ALsizei, ALuint*);
    alias alDeleteSourcesFunc           = void function(ALsizei, const(ALuint)*);
    alias alIsSourceFunc                = ALboolean function(ALuint);
    alias alSourcefFunc                 = void function(ALuint, ALenum, ALfloat);
    alias alSource3fFunc                = void function(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    alias alSourcefvFunc                = void function(ALuint, ALenum, const(ALfloat)*);
    alias alSourceiFunc                 = void function(ALuint, ALenum, ALint);
    alias alSource3iFunc                = void function(ALuint, ALenum, ALint, ALint, ALint);
    alias alSourceivFunc                = void function(ALuint, ALenum, const(ALint)*);
    alias alGetSourcefFunc              = void function(ALuint, ALenum, ALfloat*);
    alias alGetSource3fFunc             = void function(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias alGetSourcefvFunc             = void function(ALuint, ALenum, ALfloat*);
    alias alGetSourceiFunc              = void function(ALuint, ALenum, ALint*);
    alias alGetSource3iFunc             = void function(ALuint, ALenum, ALint*, ALint*, ALint*);
    alias alGetSourceivFunc             = void function(ALuint, ALenum, ALint*);
    alias alSourcePlayvFunc             = void function(ALsizei, const(ALuint)*);
    alias alSourceStopvFunc             = void function(ALsizei, const(ALuint)*);
    alias alSourceRewindvFunc           = void function(ALsizei, const(ALuint)*);
    alias alSourcePausevFunc            = void function(ALsizei, const(ALuint)*);
    alias alSourcePlayFunc              = void function(ALuint);
    alias alSourcePauseFunc             = void function(ALuint);
    alias alSourceRewindFunc            = void function(ALuint);
    alias alSourceStopFunc              = void function(ALuint);
    alias alSourceQueueBuffersFunc      = void function(ALuint, ALsizei, ALuint*);
    alias alSourceUnqueueBuffersFunc    = void function(ALuint, ALsizei, ALuint*);
    alias alGenBuffersFunc              = void function(ALsizei, ALuint*);
    alias alDeleteBuffersFunc           = void function(ALsizei, const(ALuint)*);
    alias alIsBufferFunc                = ALboolean function(ALuint);
    alias alBufferDataFunc              = void function(ALuint, ALenum, const(ALvoid)*, ALsizei, ALsizei);
    alias alBufferfFunc                 = void function(ALuint, ALenum, ALfloat);
    alias alBuffer3fFunc                = void function(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    alias alBufferfvFunc                = void function(ALuint, ALenum, const(ALfloat)*);
    alias alBufferiFunc                 = void function(ALuint, ALenum, ALint);
    alias alBuffer3iFunc                = void function(ALuint, ALenum, ALint, ALint, ALint);
    alias alBufferivFunc                = void function(ALuint, ALenum, const(ALint)*);
    alias alGetBufferfFunc              = void function(ALuint, ALenum, ALfloat*);
    alias alGetBuffer3fFunc             = void function(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias alGetBufferfvFunc             = void function(ALuint, ALenum, ALfloat*);
    alias alGetBufferiFunc              = void function(ALuint, ALenum, ALint*);
    alias alGetBuffer3iFunc             = void function(ALuint, ALenum, ALint*, ALint*, ALint*);
    alias alGetBufferivFunc             = void function(ALuint, ALenum, ALint*);
    alias alDopplerFactorFunc           = void function(ALfloat);
    alias alDopplerVelocityFunc         = void function(ALfloat);
    alias alSpeedOfSoundFunc            = void function(ALfloat);
    alias alDistanceModelFunc           = void function(ALenum);
    alias alcCreateContextFunc          = ALCcontext* function(ALCdevice*, const(ALCint)*);
    alias alcMakeContextCurrentFunc     = ALCboolean function(ALCcontext*);
    alias alcProcessContextFunc         = void function(ALCcontext*);
    alias alcSuspendContextFunc         = void function(ALCcontext*);
    alias alcDestroyContextFunc         = void function(ALCcontext*);
    alias alcGetCurrentContextFunc      = ALCcontext* function();
    alias alcGetContextsDeviceFunc      = ALCdevice* function(ALCcontext*);
    alias alcOpenDeviceFunc             = ALCdevice* function(const(char)*);
    alias alcCloseDeviceFunc            = ALCboolean function(ALCdevice*);
    alias alcGetErrorFunc               = ALCenum function(ALCdevice*);
    alias alcIsExtensionPresentFunc     = ALCboolean function(ALCdevice*, const(char)*);
    alias alcGetProcAddressFunc         = void* function(ALCdevice*, const(char)*);
    alias alcGetEnumValueFunc           = ALCenum function(ALCdevice*, const(char)*);
    alias alcGetStringFunc              = const(char)* function(ALCdevice*, ALCenum);
    alias alcGetIntegervFunc            = void function(ALCdevice*, ALCenum, ALCsizei, ALCint*);
    alias alcCaptureOpenDeviceFunc      = ALCdevice* function(const(char)*, ALCuint, ALCenum, ALCsizei);
    alias alcCaptureCloseDeviceFunc     = ALCboolean function(ALCdevice*);
    alias alcCaptureStartFunc           = void function(ALCdevice*);
    alias alcCaptureStopFunc            = void function(ALCdevice*);
    alias alcCaptureSamplesFunc         = void function(ALCdevice*, ALCvoid*, ALCsizei);

    //EFX

    // Effects
    alias alGenEffectsFunc              = void function(ALsizei, ALuint*);
    alias alDeleteEffectsFunc           = void function(ALsizei, const(ALuint)*);
    alias alIsEffectFunc                = ALboolean function(ALuint);
    alias alEffectiFunc                 = void function(ALuint, ALenum, ALint);
    alias alEffectivFunc                = void function(ALuint, ALenum, const(ALint)*);
    alias alEffectfFunc                 = void function(ALuint, ALenum, ALfloat);
    alias alEffectfvFunc                = void function(ALuint, ALenum, const(ALfloat)*);
    alias alGetEffectiFunc              = void function(ALuint, ALenum, ALint);
    alias alGetEffectivFunc             = void function(ALuint, ALenum, ALint*);
    alias alGetEffectfFunc              = void function(ALuint, ALenum, ALfloat);
    alias alGetEffectfvFunc             = void function(ALuint, ALenum, ALfloat*);

    // Filters
    alias alGenFiltersFunc              = void function(ALsizei, ALuint*);
    alias alDeleteFiltersFunc           = void function(ALsizei, const(ALuint)*);
    alias alIsFilterFunc                = ALboolean function(ALuint);
    alias alFilteriFunc                 = void function(ALuint, ALenum, ALint);
    alias alFilterivFunc                = void function(ALuint, ALenum, const(ALint)*);
    alias alFilterfFunc                 = void function(ALuint, ALenum, ALfloat);
    alias alFilterfvFunc                = void function(ALuint, ALenum, const(ALfloat)*);
    alias alGetFilteriFunc              = void function(ALuint, ALenum, ALint);
    alias alGetFilterivFunc             = void function(ALuint, ALenum, ALint*);
    alias alGetFilterfFunc              = void function(ALuint, ALenum, ALfloat);
    alias alGetFilterfvFunc             = void function(ALuint, ALenum, ALfloat*);

    // Filters
    alias alGenAuxiliaryEffectSlotsFunc                 = void function(ALsizei, ALuint*);
    alias alDeleteAuxiliaryEffectSlotFunc               = void function(ALsizei, const(ALuint)*);
    alias alIsAuxiliaryEffectSlotFunc                   = ALboolean function(ALuint);
    alias alAuxiliaryEffectSlotiFunc                    = void function(ALuint, ALenum, ALint);
    alias alAuxiliaryEffectSlotivFunc                   = void function(ALuint, ALenum, const(ALint)*);
    alias alAuxiliaryEffectSlotfFunc                    = void function(ALuint, ALenum, ALfloat);
    alias alAuxiliaryEffectSlotfvFunc                   = void function(ALuint, ALenum, const(ALfloat)*);
    alias alGetAuxiliaryEffectSlotiFunc                 = void function(ALuint, ALenum, ALint);
    alias alGetAuxiliaryEffectSlotivFunc                = void function(ALuint, ALenum, ALint*);
    alias alGetAuxiliaryEffectSlotfFunc                 = void function(ALuint, ALenum, ALfloat);
    alias alGetAuxiliaryEffectSlotfvFunc                = void function(ALuint, ALenum, ALfloat*);
}

__gshared {
    alEnableFunc				        alEnable;
    alDisableFunc				        alDisable;
    alIsEnabledFunc				        alIsEnabled;
    alGetStringFunc				        alGetString;
    alGetBooleanvFunc				    alGetBooleanv;
    alGetIntegervFunc				    alGetIntegerv;
    alGetFloatvFunc				        alGetFloatv;
    alGetDoublevFunc				    alGetDoublev;
    alGetBooleanFunc				    alGetBoolean;
    alGetIntegerFunc				    alGetInteger;
    alGetFloatFunc				        alGetFloat;
    alGetDoubleFunc				        alGetDouble;
    alGetErrorFunc				        alGetError;
    alIsExtensionPresentFunc		    alIsExtensionPresent;
    alGetProcAddressFunc			    alGetProcAddress;
    alGetEnumValueFunc				    alGetEnumValue;
    alListenerfFunc				        alListenerf;
    alListener3fFunc				    alListener3f;
    alListenerfvFunc				    alListenerfv;
    alListeneriFunc				        alListeneri;
    alListener3iFunc				    alListener3i;
    alListenerivFunc				    alListeneriv;
    alGetListenerfFunc				    alGetListenerf;
    alGetListener3fFunc				    alGetListener3f;
    alGetListenerfvFunc				    alGetListenerfv;
    alGetListeneriFunc				    alGetListeneri;
    alGetListener3iFunc				    alGetListener3i;
    alGetListenerivFunc				    alGetListeneriv;

    alGenSourcesFunc				    alGenSources;
    alDeleteSourcesFunc				    alDeleteSources;
    alIsSourceFunc				        alIsSource;
    alSourcefFunc				        alSourcef;
    alSource3fFunc				        alSource3f;
    alSourcefvFunc			    	    alSourcefv;
    alSourceiFunc				        alSourcei;
    alSource3iFunc				        alSource3i;
    alSourceivFunc				        alSourceiv;
    alGetSourcefFunc				    alGetSourcef;
    alGetSource3fFunc				    alGetSource3f;
    alGetSourcefvFunc				    alGetSourcefv;
    alGetSourceiFunc				    alGetSourcei;
    alGetSource3iFunc				    alGetSource3i;
    alGetSourceivFunc				    alGetSourceiv;
    alSourcePlayvFunc				    alSourcePlayv;
    alSourceStopvFunc				    alSourceStopv;
    alSourceRewindvFunc				    alSourceRewindv;
    alSourcePausevFunc				    alSourcePausev;
    alSourcePlayFunc				    alSourcePlay;
    alSourcePauseFunc				    alSourcePause;
    alSourceRewindFunc				    alSourceRewind;
    alSourceStopFunc				    alSourceStop;
    alSourceQueueBuffersFunc		    alSourceQueueBuffers;
    alSourceUnqueueBuffersFunc		    alSourceUnqueueBuffers;

    alGenBuffersFunc				    alGenBuffers;
    alDeleteBuffersFunc				    alDeleteBuffers;
    alIsBufferFunc				        alIsBuffer;
    alBufferDataFunc				    alBufferData;
    alBufferfFunc				        alBufferf;
    alBuffer3fFunc				        alBuffer3f;
    alBufferfvFunc				        alBufferfv;
    alBufferiFunc				        alBufferi;
    alBuffer3iFunc				        alBuffer3i;
    alBufferivFunc				        alBufferiv;
    alGetBufferfFunc				    alGetBufferf;
    alGetBuffer3fFunc				    alGetBuffer3f;
    alGetBufferfvFunc				    alGetBufferfv;
    alGetBufferiFunc				    alGetBufferi;
    alGetBuffer3iFunc				    alGetBuffer3i;
    alGetBufferivFunc				    alGetBufferiv;
    alDopplerFactorFunc				    alDopplerFactor;
    alDopplerVelocityFunc			    alDopplerVelocity;
    alSpeedOfSoundFunc				    alSpeedOfSound;
    alDistanceModelFunc				    alDistanceModel;
    alcCreateContextFunc			    alcCreateContext;
    alcMakeContextCurrentFunc		    alcMakeContextCurrent;
    alcProcessContextFunc			    alcProcessContext;
    alcSuspendContextFunc			    alcSuspendContext;
    alcDestroyContextFunc			    alcDestroyContext;
    alcGetCurrentContextFunc		    alcGetCurrentContext;
    alcGetContextsDeviceFunc		    alcGetContextsDevice;
    alcOpenDeviceFunc				    alcOpenDevice;
    alcCloseDeviceFunc				    alcCloseDevice;
    alcGetErrorFunc				        alcGetError;
    alcIsExtensionPresentFunc		    alcIsExtensionPresent;
    alcGetProcAddressFunc			    alcGetProcAddress;
    alcGetEnumValueFunc				    alcGetEnumValue;
    alcGetStringFunc				    alcGetString;
    alcGetIntegervFunc				    alcGetIntegerv;
    alcCaptureOpenDeviceFunc		    alcCaptureOpenDevice;
    alcCaptureCloseDeviceFunc		    alcCaptureCloseDevice;
    alcCaptureStartFunc				    alcCaptureStart;
    alcCaptureStopFunc				    alcCaptureStop;
    alcCaptureSamplesFunc               alcCaptureSamples;

    // EFX

    // Effects
    alGenEffectsFunc                    alGenEffects;
    alDeleteEffectsFunc                 alDeleteEffects;
    alIsEffectFunc                      alIsEffect;
    alEffectiFunc                       alEffecti;
    alEffectivFunc                      alEffectiv;
    alEffectfFunc                       alEffectf;
    alEffectfvFunc                      alEffectfv;
    alGetEffectiFunc                    alGetEffecti;
    alGetEffectivFunc                   alGetEffectiv;
    alGetEffectfFunc                    alGetEffectf;
    alGetEffectfvFunc                   alGetEffectfv;

    // Filters
    alGenFiltersFunc                    alGenFilters;
    alDeleteFiltersFunc                 alDeleteFilters;
    alIsFilterFunc                      alIsFilter;
    alFilteriFunc                       alFilteri;
    alFilterivFunc                      alFilteriv;
    alFilterfFunc                       alFilterf;
    alFilterfvFunc                      alFilterfv;
    alGetFilteriFunc                    alGetFilteri;
    alGetFilterivFunc                   alGetFilteriv;
    alGetFilterfFunc                    alGetFilterf;
    alGetFilterfvFunc                   alGetFilterfv;

    // Auxiliary Effect Slots
    alGenAuxiliaryEffectSlotsFunc       alGenAuxiliaryEffectSlots;
    alDeleteAuxiliaryEffectSlotFunc     alDeleteAuxiliaryEffectSlots;
    alIsAuxiliaryEffectSlotFunc         alIsAuxiliaryEffectSlot;
    alAuxiliaryEffectSlotiFunc          alAuxiliaryEffectSloti;
    alAuxiliaryEffectSlotivFunc         alAuxiliaryEffectSlotiv;
    alAuxiliaryEffectSlotfFunc          alAuxiliaryEffectSlotf;
    alAuxiliaryEffectSlotfvFunc         alAuxiliaryEffectSlotfv;
    alGetAuxiliaryEffectSlotiFunc       alGetAuxiliaryEffectSloti;
    alGetAuxiliaryEffectSlotivFunc      alGetAuxiliaryEffectSlotiv;
    alGetAuxiliaryEffectSlotfFunc       alGetAuxiliaryEffectSlotf;
    alGetAuxiliaryEffectSlotfvFunc      alGetAuxiliaryEffectSlotfv;            
}

private {
    SharedLib lib;
}

version(Windows) {
    enum libNames = "OpenAl32.dll,oal_soft.dll";
} else version(OSX) {
    enum libNames = "../Frameworks/OpenAL.framework/OpenAL, /Library/Frameworks/OpenAL.framework/OpenAL, /System/Library/Frameworks/OpenAL.framework/OpenAL";
} else version(Posix) {
    enum libNames = "libal.so,libAL.so,libopenal.so,libopenal.so.1,libopenal.so.0,liboalsoft.so";
} else {
    enum libNames = "NOT_SUPPORTED";
}

void unloadOAL() {
    if (lib != invalidHandle) {
        lib.unload();
    }
}

bool loadOAL() {
    if (libNames == "NOT_SUPPORTED") throw new Exception("OpenAL not supported on your platform currently.");
    foreach (lib; libNames.split(',')) {
        if (loadOAL(lib.dup.ptr)) return true;
    }
    return false;
}

bool loadOAL(const(char)* libName) {
    if (lib == invalidHandle) {
        lib = load(libName);
        if (lib == invalidHandle) {
            return false;
        }
    }

    auto errCount = errorCount();
    lib.bindSymbol(cast(void**)&alEnable, "alEnable");
    lib.bindSymbol(cast(void**)&alDisable, "alDisable");
    lib.bindSymbol(cast(void**)&alIsEnabled, "alIsEnabled");
    lib.bindSymbol(cast(void**)&alGetString, "alGetString");
    lib.bindSymbol(cast(void**)&alGetBooleanv, "alGetBooleanv");
    lib.bindSymbol(cast(void**)&alGetIntegerv, "alGetIntegerv");
    lib.bindSymbol(cast(void**)&alGetFloatv, "alGetFloatv");
    lib.bindSymbol(cast(void**)&alGetDoublev, "alGetDoublev");
    lib.bindSymbol(cast(void**)&alGetInteger, "alGetInteger");
    lib.bindSymbol(cast(void**)&alGetFloat, "alGetFloat");
    lib.bindSymbol(cast(void**)&alGetDouble, "alGetDouble");
    lib.bindSymbol(cast(void**)&alGetError, "alGetError");
    lib.bindSymbol(cast(void**)&alIsExtensionPresent, "alIsExtensionPresent");
    lib.bindSymbol(cast(void**)&alGetProcAddress, "alGetProcAddress");
    lib.bindSymbol(cast(void**)&alGetEnumValue, "alGetEnumValue");
    lib.bindSymbol(cast(void**)&alListenerf, "alListenerf");
    lib.bindSymbol(cast(void**)&alListener3f, "alListener3f");
    lib.bindSymbol(cast(void**)&alListenerfv, "alListenerfv");
    lib.bindSymbol(cast(void**)&alListeneri, "alListeneri");
    lib.bindSymbol(cast(void**)&alListener3i, "alListener3i");
    lib.bindSymbol(cast(void**)&alListeneriv, "alListeneriv");
    lib.bindSymbol(cast(void**)&alGetListenerf, "alGetListenerf");
    lib.bindSymbol(cast(void**)&alGetListener3f, "alGetListener3f");
    lib.bindSymbol(cast(void**)&alGetListenerfv, "alGetListenerfv");
    lib.bindSymbol(cast(void**)&alGetListeneri, "alGetListeneri");
    lib.bindSymbol(cast(void**)&alGetListener3i, "alGetListener3i");
    lib.bindSymbol(cast(void**)&alGetListeneriv, "alGetListeneriv");
    lib.bindSymbol(cast(void**)&alGenSources, "alGenSources");
    lib.bindSymbol(cast(void**)&alDeleteSources, "alDeleteSources");
    lib.bindSymbol(cast(void**)&alIsSource, "alIsSource");
    lib.bindSymbol(cast(void**)&alSourcef, "alSourcef");
    lib.bindSymbol(cast(void**)&alSource3f, "alSource3f");
    lib.bindSymbol(cast(void**)&alSourcefv, "alSourcefv");
    lib.bindSymbol(cast(void**)&alSourcei, "alSourcei");
    lib.bindSymbol(cast(void**)&alSource3i, "alSource3i");
    lib.bindSymbol(cast(void**)&alSourceiv, "alSourceiv");
    lib.bindSymbol(cast(void**)&alGetSourcef, "alGetSourcef");
    lib.bindSymbol(cast(void**)&alGetSource3f, "alGetSource3f");
    lib.bindSymbol(cast(void**)&alGetSourcefv, "alGetSourcefv");
    lib.bindSymbol(cast(void**)&alGetSourcei, "alGetSourcei");
    lib.bindSymbol(cast(void**)&alGetSource3i, "alGetSource3i");
    lib.bindSymbol(cast(void**)&alGetSourceiv, "alGetSourceiv");
    lib.bindSymbol(cast(void**)&alSourcePlayv, "alSourcePlayv");
    lib.bindSymbol(cast(void**)&alSourceStopv, "alSourceStopv");
    lib.bindSymbol(cast(void**)&alSourceRewindv, "alSourceRewindv");
    lib.bindSymbol(cast(void**)&alSourcePausev, "alSourcePausev");
    lib.bindSymbol(cast(void**)&alSourcePlay, "alSourcePlay");
    lib.bindSymbol(cast(void**)&alSourcePause, "alSourcePause");
    lib.bindSymbol(cast(void**)&alSourceRewind, "alSourceRewind");
    lib.bindSymbol(cast(void**)&alSourceStop, "alSourceStop");
    lib.bindSymbol(cast(void**)&alSourceQueueBuffers, "alSourceQueueBuffers");
    lib.bindSymbol(cast(void**)&alSourceUnqueueBuffers, "alSourceUnqueueBuffers");
    lib.bindSymbol(cast(void**)&alGenBuffers, "alGenBuffers");
    lib.bindSymbol(cast(void**)&alDeleteBuffers, "alDeleteBuffers");
    lib.bindSymbol(cast(void**)&alIsBuffer, "alIsBuffer");
    lib.bindSymbol(cast(void**)&alBufferData, "alBufferData");
    lib.bindSymbol(cast(void**)&alBufferf, "alBufferf");
    lib.bindSymbol(cast(void**)&alBuffer3f, "alBuffer3f");
    lib.bindSymbol(cast(void**)&alBufferfv, "alBufferfv");
    lib.bindSymbol(cast(void**)&alBufferi, "alBufferi");
    lib.bindSymbol(cast(void**)&alBuffer3i, "alBuffer3i");
    lib.bindSymbol(cast(void**)&alBufferiv, "alBufferiv");
    lib.bindSymbol(cast(void**)&alGetBufferf, "alGetBufferf");
    lib.bindSymbol(cast(void**)&alGetBuffer3f, "alGetBuffer3f");
    lib.bindSymbol(cast(void**)&alGetBufferfv, "alGetBufferfv");
    lib.bindSymbol(cast(void**)&alGetBufferi, "alGetBufferi");
    lib.bindSymbol(cast(void**)&alGetBuffer3i, "alGetBuffer3i");
    lib.bindSymbol(cast(void**)&alGetBufferiv, "alGetBufferiv");
    lib.bindSymbol(cast(void**)&alDopplerFactor, "alDopplerFactor");
    lib.bindSymbol(cast(void**)&alDopplerVelocity, "alDopplerVelocity");
    lib.bindSymbol(cast(void**)&alSpeedOfSound, "alSpeedOfSound");
    lib.bindSymbol(cast(void**)&alDistanceModel, "alDistanceModel");
    lib.bindSymbol(cast(void**)&alcCreateContext, "alcCreateContext");
    lib.bindSymbol(cast(void**)&alcMakeContextCurrent, "alcMakeContextCurrent");
    lib.bindSymbol(cast(void**)&alcProcessContext, "alcProcessContext");
    lib.bindSymbol(cast(void**)&alcGetCurrentContext, "alcGetCurrentContext");
    lib.bindSymbol(cast(void**)&alcGetContextsDevice, "alcGetContextsDevice");
    lib.bindSymbol(cast(void**)&alcSuspendContext, "alcSuspendContext");
    lib.bindSymbol(cast(void**)&alcDestroyContext, "alcDestroyContext");
    lib.bindSymbol(cast(void**)&alcOpenDevice, "alcOpenDevice");
    lib.bindSymbol(cast(void**)&alcCloseDevice, "alcCloseDevice");
    lib.bindSymbol(cast(void**)&alcGetError, "alcGetError");
    lib.bindSymbol(cast(void**)&alcIsExtensionPresent, "alcIsExtensionPresent");
    lib.bindSymbol(cast(void**)&alcGetProcAddress, "alcGetProcAddress");
    lib.bindSymbol(cast(void**)&alcGetEnumValue, "alcGetEnumValue");
    lib.bindSymbol(cast(void**)&alcGetString, "alcGetString");
    lib.bindSymbol(cast(void**)&alcGetIntegerv, "alcGetIntegerv");
    lib.bindSymbol(cast(void**)&alcCaptureOpenDevice, "alcCaptureOpenDevice");
    lib.bindSymbol(cast(void**)&alcCaptureCloseDevice, "alcCaptureCloseDevice");
    lib.bindSymbol(cast(void**)&alcCaptureStart, "alcCaptureStart");
    lib.bindSymbol(cast(void**)&alcCaptureStop, "alcCaptureStop");
    lib.bindSymbol(cast(void**)&alcCaptureSamples, "alcCaptureSamples");

    // EFX

    // Effects
    lib.bindSymbol(cast(void**)&alGenEffects,       "alGenEffects");
    lib.bindSymbol(cast(void**)&alDeleteEffects,    "alDeleteEffects");
    lib.bindSymbol(cast(void**)&alIsEffect,         "alIsEffect");
    lib.bindSymbol(cast(void**)&alEffecti,          "alEffecti");
    lib.bindSymbol(cast(void**)&alEffectiv,         "alEffectiv");
    lib.bindSymbol(cast(void**)&alEffectf,          "alEffectf");
    lib.bindSymbol(cast(void**)&alEffectfv,         "alEffectfv");
    lib.bindSymbol(cast(void**)&alGetEffecti,       "alGetEffecti");
    lib.bindSymbol(cast(void**)&alGetEffectiv,      "alGetEffectiv");
    lib.bindSymbol(cast(void**)&alGetEffectf,       "alGetEffectf");
    lib.bindSymbol(cast(void**)&alGetEffectfv,      "alGetEffectfv");

    // Filters
    lib.bindSymbol(cast(void**)&alGenFilters,       "alGenFilters");
    lib.bindSymbol(cast(void**)&alDeleteFilters,    "alDeleteFilters");
    lib.bindSymbol(cast(void**)&alIsFilter,         "alIsFilter");
    lib.bindSymbol(cast(void**)&alFilteri,          "alFilteri");
    lib.bindSymbol(cast(void**)&alFilteriv,         "alFilteriv");
    lib.bindSymbol(cast(void**)&alFilterf,          "alFilterf");
    lib.bindSymbol(cast(void**)&alFilterfv,         "alFilterfv");
    lib.bindSymbol(cast(void**)&alGetFilteri,       "alGetFilteri");
    lib.bindSymbol(cast(void**)&alGetFilteriv,      "alGetFilteriv");
    lib.bindSymbol(cast(void**)&alGetFilterf,       "alGetFilterf");
    lib.bindSymbol(cast(void**)&alGetFilterfv,      "alGetFilterfv");

    // Filters
    lib.bindSymbol(cast(void**)&alGenAuxiliaryEffectSlots,      "alGenAuxiliaryEffectSlots");
    lib.bindSymbol(cast(void**)&alDeleteAuxiliaryEffectSlots,   "alDeleteAuxiliaryEffectSlots");
    lib.bindSymbol(cast(void**)&alIsAuxiliaryEffectSlot,        "alIsAuxiliaryEffectSlot");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSloti,         "alAuxiliaryEffectSloti");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotiv,        "alAuxiliaryEffectSlotiv");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotf,         "alAuxiliaryEffectSlotf");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotfv,        "alAuxiliaryEffectSlotfv");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSloti,      "alGetAuxiliaryEffectSloti");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotiv,     "alGetAuxiliaryEffectSlotiv");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotf,      "alGetAuxiliaryEffectSlotf");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotfv,     "alGetAuxiliaryEffectSlotfv");


    return errCount == errorCount();
}