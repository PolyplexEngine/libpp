module polyplex.core;

public import polyplex.core.game;
public import polyplex.core.render;
public import polyplex.core.rendersurface;
public import polyplex.core.locale;
public import polyplex.core.input;
public import polyplex.core.content;
public import polyplex.core.color;
public import polyplex.core.rendersurface;
public import polyplex.core.surfaces;

import polyplex;
import polyplex.utils;

public class BasicGameLauncher
{
	/**
		Removes the first element in the arguments array.
		(this value is generally the name of the executable and unneeded.)
	*/
	public static string[] ProcessArgs(string[] args) {
		return args[1..$];
	}

	private static void launch(Game game, string[] args) {
		foreach (arg; args) {
			if (arg == "--no-autofocus") {
				game.Surface.AutoFocus = false;
			}
			else if (arg == "--opengl") {
				ChosenBackend = GraphicsBackend.OpenGL;
			}
		}
		Logger.Info("Set rendering backend to {0}...", ChosenBackend);
		do_launch(game);
	}

	private static void do_launch(Game game) {
		ChosenBackend = GraphicsBackend.OpenGL;
		InitLibraries();
		game.Run();
	}

	public static void InitSDL() {
		ChosenBackend = GraphicsBackend.OpenGL;
		InitLibraries();
	}

	public static void LaunchGame(Game g, string[] args) {
		Logger.Debug("Launching {0} with args {1}...", g.Surface.Title, args);
		launch(g, args);
	}
}
