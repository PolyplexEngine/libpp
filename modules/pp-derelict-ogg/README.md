DerelictOgg
==========

A dynamic binding to [libogg][1] version 1.3 for the D Programming Language.

Please see the sections on [Compiling and Linking][2] and [The Derelict Loader][3], in the Derelict documentation, for information on how to build DerelictOgg and load libogg at run time. In the meantime, here's some sample code.

```D
import derelict.ogg.ogg;

void main() {
    // Load the libogg library.
    DerelictOgg.load();

    // Now libogg functions can be called.
    ...
}
```

[1]: http://xiph.org/ogg/
[2]: http://derelictorg.github.io/building/overview/
[3]: http://derelictorg.github.io/loading/loader/