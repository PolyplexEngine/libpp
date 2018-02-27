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
	private static void launch(Game game, string[] args)
	{
		try
		{
			ChosenBackend = GraphicsBackend.Vulkan;
			if (args.length == 2)
			{
				if (args[1] == "-vulkan")
				{
					ChosenBackend = GraphicsBackend.Vulkan;
				}
				else if (args[1] == "-opengl")
				{
					ChosenBackend = GraphicsBackend.OpenGL;
				}
			}
			Logger.Info("Set rendering backend to {0}...", ChosenBackend);
			do_launch(game);
		}
		catch (Exception ex)
		{
			Logger.Info("Application failed! {0}", ex);
		}
	}

	private static void do_launch(Game game)
	{
		try
		{
			if (ChosenBackend == GraphicsBackend.Vulkan)
			{
				try
				{
					InitLibraries();
					game.Run();
				}
				catch
				{
					Logger.Recover("Going to OpenGL fallback mode...");
					ChosenBackend = GraphicsBackend.OpenGL;
					do_launch(game);
				}
			}
			else
			{
				InitLibraries();
				game.Run();
			}
		}
		catch (Error err)
		{
			Logger.Log("Fatal Error! {0}", err, LogType.Fatal);
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