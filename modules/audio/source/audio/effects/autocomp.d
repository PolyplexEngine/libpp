module audio.effects.autocomp;
import audio.effects;
import audio.effect;
import openal;

/// An automatic compressor
public class AutoCompressorEffect : AudioEffect {
public:
    this() {
        super(EffectType.Compressor);
        setupDone();
    }

    @property bool IsOn() {
        ALint val;
        alGetEffecti(id, AL_AUTOWAH_ATTACK_TIME, &val);
        return cast(bool)val;
    }

    @property void IsOn(bool val) {
        alEffecti(id, AL_AUTOWAH_ATTACK_TIME, cast(ALint)val);
    }
}