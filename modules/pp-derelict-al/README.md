DerelictAL
==========

A dynamic binding to [OpenAL][1] for the D Programming Language.

Please see the sections on [Compiling and Linking][2] and [The Derelict Loader][3], in the Derelict documentation, for information on how to build DerelictAL and load OpenAL at run time. In the meantime, here's some sample code.

```D
import derelict.openal.al;

void main() {
    // Load the OpenAL library.
    DerelictAL.load();

    // Now OpenAL functions can be called.
    ...
}
```

[1]: http://www.openal.org/
[2]: http://derelictorg.github.io/building/overview/
[3]: http://derelictorg.github.io/loading/loader/