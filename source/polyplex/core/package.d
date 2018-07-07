module polyplex.core;

public import polyplex.core.game;
public import polyplex.core.render;
public import polyplex.core.window;
public import polyplex.core.locale;
public import polyplex.core.input;
public import polyplex.core.content;
public import polyplex.core.color;

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
		ChosenBackend = GraphicsBackend.Vulkan;
		if (args.length > 0) {
			if (args[0] == "--vulkan") {
				ChosenBackend = GraphicsBackend.Vulkan;
			}
			else if (args[0] == "--opengl") {
				ChosenBackend = GraphicsBackend.OpenGL;
			}
		}
		Logger.Info("Set rendering backend to {0}...", ChosenBackend);
		do_launch(game);
	}

	private static void do_launch(Game game) {
		try {
			if (ChosenBackend == GraphicsBackend.Vulkan) {
				try {
					InitLibraries();
					game.Run();
				}
				catch(Throwable) {
					Logger.Recover("Going to OpenGL fallback mode...");
					ChosenBackend = GraphicsBackend.OpenGL;
					do_launch(game);
				}
			} else {
				ChosenBackend = GraphicsBackend.OpenGL;
				InitLibraries();
				game.Run();
			}
		}
		catch (Error err) {
			Logger.Fatal("Fatal Error! {0}", err);
		}
	}

	public static void InitSDL() {
		ChosenBackend = GraphicsBackend.NoneChosen;
		InitLibraries();
	}

	public static void LaunchGame(Game g, string[] args) {
		Logger.Debug("Launching {0} with args {1}...", g.Window.Title, args);
		launch(g, args);
	}
}
