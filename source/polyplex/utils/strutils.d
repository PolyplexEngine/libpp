module polyplex.utils.strutils;
import std.conv;
import std.array;
import std.stdio;
import core.vararg;

/**
	C# style text formatting.
	Add {(id)} in text to specify replacement points, specified arguments (after sequential id) will replace the text with a to!string variant.
*/
public static string Format(T...)(string format, T args) {
	string result = format;
	static foreach(i; 0 .. args.length) {
		result = result.replace("{" ~ i.text ~ "}", args[i].text);
	}
	return result;
}

/*
public static string Format(string message, ...) {
	string[] formatstr;
	for (int i = 0; i < _arguments.length; i++) {
		formatstr ~= va_arg!string(_argptr);
	}
	return FormatStr(message, formatstr);
}

public static string FormatStr(string base, string[] format) {
	string o = base;
	for(int i = 0; i < format.length; i++) {
		o = replace(o, "{"~to!string(i)~"}", format[i]);
	}
	return o;
}*/
