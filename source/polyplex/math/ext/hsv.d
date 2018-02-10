module polyplex.math.ext.hsv;

private {
    import std.conv : to;
    
    import polyplex.math.linalg : vec3, vec4;
    import polyplex.math : min, max, floor;

    version(unittest) {
        import polyplex.math : almost_equal;
    }
}

/// Converts a 3 dimensional color-vector from the RGB to the HSV colorspace.
/// The function assumes that each component is in the range [0, 1].
@safe pure nothrow vec3 rgb2hsv(vec3 inp) {
    vec3 ret = vec3(0.0f, 0.0f, 0.0f);
    
    float h_max = max(inp.r, inp.g, inp.b);
    float h_min = min(inp.r, inp.g, inp.b);
    float delta = h_max - h_min;

   
    // h
    if(delta == 0.0f) {
        ret.X = 0.0f;
    } else if(inp.r == h_max) {
        ret.X = (inp.g - inp.b) / delta; // h
    } else if(inp.g == h_max) {
        ret.X = 2 + (inp.b - inp.r) / delta; // h
    } else {
        ret.X = 4 + (inp.r - inp.g) / delta; // h
    }

    ret.X = ret.X * 60;
    if(ret.X < 0) {
        ret.X = ret.X + 360;
    }

    // s
    if(h_max == 0.0f) {
        ret.Y = 0.0f;
    } else {
        ret.Y = delta / h_max;
    }

    // v
    ret.Z = h_max;

    return ret;
}

/// Converts a 4 dimensional color-vector from the RGB to the HSV colorspace.
/// The alpha value is not touched. This function also assumes that each component is in the range [0, 1].
@safe pure nothrow vec4 rgb2hsv(vec4 inp) {
    return vec4(rgb2hsv(vec3(inp.rgb)), inp.a);
}

unittest {
    assert(rgb2hsv(vec3(0.0f, 0.0f, 0.0f)) == vec3(0.0f, 0.0f, 0.0f));
    assert(rgb2hsv(vec3(1.0f, 1.0f, 1.0f)) == vec3(0.0f, 0.0f, 1.0f));

    vec3 hsv = rgb2hsv(vec3(100.0f/255.0f, 100.0f/255.0f, 100.0f/255.0f));    
    assert(hsv.X == 0.0f && hsv.Y == 0.0f && almost_equal(hsv.Z, 0.392157, 0.000001));
    
    assert(rgb2hsv(vec3(0.0f, 0.0f, 1.0f)) == vec3(240.0f, 1.0f, 1.0f));
}

/// Converts a 3 dimensional color-vector from the HSV to the RGB colorspace.
/// RGB colors will be in the range [0, 1].
/// This function is not marked es pure, since it depends on std.math.floor, which
/// is also not pure.
@safe nothrow vec3 hsv2rgb(vec3 inp) {
    if(inp.Y == 0.0f) { // s
        return vec3(inp.ZZZ); // v
    } else {
        float var_h = inp.X * 6;
        float var_i = to!float(floor(var_h));
        float var_1 = inp.Z * (1 - inp.Y);
        float var_2 = inp.Z * (1 - inp.Y * (var_h - var_i));
        float var_3 = inp.Z * (1 - inp.Y * (1 - (var_h - var_i)));

        if(var_i == 0.0f)      return vec3(inp.Z, var_3, var_1);
        else if(var_i == 1.0f) return vec3(var_2, inp.Z, var_1);
        else if(var_i == 2.0f) return vec3(var_1, inp.Z, var_3);
        else if(var_i == 3.0f) return vec3(var_1, var_2, inp.Z);
        else if(var_i == 4.0f) return vec3(var_3, var_1, inp.Z);
        else                   return vec3(inp.Z, var_1, var_2);
    }
}

/// Converts a 4 dimensional color-vector from the HSV to the RGB colorspace.
/// The alpha value is not touched and the resulting RGB colors will be in the range [0, 1].
@safe nothrow vec4 hsv2rgb(vec4 inp) {
    return vec4(hsv2rgb(vec3(inp.XYZ)), inp.W);
}

unittest {
    assert(hsv2rgb(vec3(0.0f, 0.0f, 0.0f)) == vec3(0.0f, 0.0f, 0.0f));
    assert(hsv2rgb(vec3(0.0f, 0.0f, 1.0f)) == vec3(1.0f, 1.0f, 1.0f));

    vec3 rgb = hsv2rgb(vec3(0.0f, 0.0f, 0.392157f));
    assert(rgb == vec3(0.392157f, 0.392157f, 0.392157f));

    assert(hsv2rgb(vec3(300.0f, 1.0f, 1.0f)) == vec3(1.0f, 0.0f, 1.0f));
}