module polyplex.utils.logging;
import polyplex.utils.strutils;
import std.conv;
import std.array;
import std.stdio;
import core.vararg;

public enum LogType {
	Off = 		0x00,
	Info = 		0x01,
	Success = 	0x02,
	Warning = 	0x04,
	Error = 	0x08,
	Fatal = 	0x10,
	Recover = 	0x20,
	Debug = 	0x40
}

public static LogType LogLevel = LogType.Warning | LogType.Error | LogType.Fatal;
public class Logger {

	/* Basic impl */
	public static void Log(string message, LogType type = LogType.Info)  {
		Log(message, null, type);
	}

	public static void Debug (string message) {
		Logger.Debug(message, null);
	}

	public static void Success (string message) {
		Logger.Success(message, null);
	}

	public static void Info (string message) {
		Logger.Info(message, null);
	}

	public static void Warn (string message) {
		Logger.Warn(message, null);
	}

	public static void Err (string message) {
		Logger.Err(message, null);
	}

	public static void Fatal (string message) {
		Logger.Fatal(message, null);
	}

	public static void Recover (string message) {
		Logger.Recover(message, null);
	}

	/*T... impl.*/

	public static void Debug(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Info);
	}

	public static void Info(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Info);
	}

	public static void Success(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Success);
	}

	public static void Warn(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Warning);
	}

	public static void Err(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Error);
	}

	public static void Fatal(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Fatal);
	}

	public static void Recover(T...) (string message, T args) {
		Logger.Log(message, args, LogType.Recover);
	}

	/* Raw impl */

	public static void Log(T...) (string message, T args, LogType type = LogType.Info)  {
		bool color = false;
		if ((LogLevel != LogType.Off && (LogLevel & type)) || (type == LogType.Fatal || type == LogType.Recover)) {
			import colorize : fg, color, cwriteln;
			string stxt = to!string(type);
			if (type == LogType.Debug) stxt = stxt.color(fg.blue);
			if (type == LogType.Info) stxt = stxt.color(fg.light_black);
			if (type == LogType.Success) stxt = stxt.color(fg.light_green);
			if (type == LogType.Warning) stxt = stxt.color(fg.yellow);
			if (type == LogType.Error) stxt = stxt.color(fg.light_red);
			if (type == LogType.Fatal) stxt = stxt.color(fg.red);
			if (type == LogType.Recover) stxt = stxt.color(fg.light_blue);
			string txt = "<".color(fg.light_black) ~ stxt ~ ">".color(fg.light_black);
			cwriteln(txt, " ", Format(message, args));
		}
		if (type == LogType.Fatal) throw new Exception(Format(message, args));
	}

}