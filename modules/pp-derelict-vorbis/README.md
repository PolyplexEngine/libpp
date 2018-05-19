DerelictVorbis
==========

A dynamic binding to [libvorbis][1] version 1.3 for the D Programming Language.

Please see the sections on [Compiling and Linking][2] and [The Derelict Loader][3], for information on how to build DerelictVorbis and load libvorbis at run time. In the meantime, here's some sample code.

```D
import derelict.vorbis.vorbis;
import derelict.vorbis.enc;
import derelict.vorbis.file;

void main() {
    // Load the libvorbis library and its companion encoding and file libaries.
    import derelict.vorbis;

    /* Alternatively:
    import derelict.vorbis.codec,
           derelict.vorbis.enc,
           derelict.vorbis.file;
    */
    DerelictVorbis.load();
    DerelictVorbisEnc.load();
    DerelictVorbisFile.load();

    // Now libvorbis functions can be called.
    ...
}
```

[1]: http://xiph.org/vorbis/
[2]: http://derelictorg.github.io/building/overview/
[3]: http://derelictorg.github.io/loading/loader/