module polyplex.core.audio.effects.eq;
import polyplex.core.audio.effect;
import openal;

/// An equalizer.
public class EqualizerEffect : AudioEffect {
public:
    this() {
        super(EffectType.Equalizer);
    }
}