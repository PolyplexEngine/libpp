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
	Debug = 	0x40,
	VerboseDebug = 	0x80
}

public static LogType LogLevel = LogType.Recover | LogType.Success | LogType.Warning | LogType.Error | LogType.Fatal;
public class Logger {

	/**
		Allows you to put a log of LogType type with an simple string message.
	*/
	public static void Log(string message, LogType type = LogType.Info)  {
		Log(message, type, null);
	}

	/**
		Log a verbose debug message. <No extra parameters>
	*/
	public static void VerboseDebug (string message) {
		Logger.VerboseDebug(message, null);
	}

	/**
		Log a debug message. <No extra parameters>
	*/
	public static void Debug (string message) {
		Logger.Debug(message, null);
	}

	/**
		Log a success message. <No extra parameters>
	*/
	public static void Success (string message) {
		Logger.Success(message, null);
	}

	/**
		Log an info message. <No extra parameters>
	*/
	public static void Info (string message) {
		Logger.Info(message, null);
	}

	/**
		Log a warning message. <No extra parameters>
	*/
	public static void Warn (string message) {
		Logger.Warn(message, null);
	}

	/**
		Log a Error message. <No extra parameters>
	*/
	public static void Err (string message) {
		Logger.Err(message, null);
	}

	/**
		Log a Fatal Error message. <No extra parameters>
	*/
	public static void Fatal (string message) {
		Logger.Fatal(message, null);
	}

	/**
		Log an Error Recovery message. <No extra parameters>
	*/
	public static void Recover (string message) {
		Logger.Recover(message, null);
	}

	/**
		Log a verbose debug message.
	*/
	public static void VerboseDebug(T...) (string message, T args) {
		Logger.Log(message, LogType.VerboseDebug, args);
	}

	/**
		Log a debug message.
	*/
	public static void Debug(T...) (string message, T args) {
		Logger.Log(message, LogType.Debug, args);
	}

	/**
		Log an info message.
	*/
	public static void Info(T...) (string message, T args) {
		Logger.Log(message, LogType.Info, args);
	}

	/**
		Log a success message.
	*/
	public static void Success(T...) (string message, T args) {
		Logger.Log(message, LogType.Success, args);
	}

	/**
		Log a warning message.
	*/
	public static void Warn(T...) (string message, T args) {
		Logger.Log(message, LogType.Warning, args);
	}

	/**
		Log an Error message.
	*/
	public static void Err(T...) (string message, T args) {
		Logger.Log(message, LogType.Error, args);
	}

	/**
		Log a Fatal Error message.
	*/
	public static void Fatal(T...) (string message, T args) {
		Logger.Log(message, LogType.Fatal, args);
	}

	/**
		Log a Error Recovery message.
	*/
	public static void Recover(T...) (string message, T args) {
		Logger.Log(message, LogType.Recover, args);
	}

	/* Raw impl */

	public static void Log(T...) (string message, LogType type, T args)  {
		bool color = false;
		if ((LogLevel != LogType.Off && (LogLevel & type)) || (type == LogType.Fatal || type == LogType.Recover)) {
			import colorize : fg, color, cwriteln;
			string stxt = to!string(type);
			if (type == LogType.VerboseDebug) stxt = stxt.color(fg.cyan);
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
