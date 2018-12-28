module polyplex.core.audio.effects.autocomp;
import polyplex.core.audio.effects;
import polyplex.core.audio.effect;
import openal;

/// A frequency shifter
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