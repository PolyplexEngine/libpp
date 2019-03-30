import audio;
import audio.effects;
import audio.filters;
import std.stdio;
import core.thread;
import std.math;

void main() {
    writeln("Constructing surface...");
    
    
    // writeln("Devices: ", GetDevices(), "; Default: ", GetDefaultDevice());
    
    // LowpassFilter lp = new LowpassFilter();
    // lp.GainHF = .1;
    // lp.GainBase = 1f;

    // ChorusEffect reverb = new ChorusEffect();
    
    // Music mus = Music.fromFile("test_audio.ogg");
    // mus.Effect = reverb;
    // mus.Filter = lp;
    // mus.Send = 1;
    // mus.Play(true);
    // float x = 1f;
    // while (mus.Playing) {
    //     Thread.sleep(200.msecs);
    // }
}