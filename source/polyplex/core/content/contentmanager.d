module polyplex.core.content.contentmanager;
import polyplex.core.content.textures;
import polyplex.core.content.gl;
import polyplex.core.content.vk;
import polyplex.core.content.font;
import polyplex.core.content.data;
import polyplex.core.content.audio;
import polyplex.utils.logging;
import polyplex.utils.strutils;

static import ppc;

import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.sdl;

public enum SupportedAudio {
	FLAC,
	MOD,
	MP3,
	OGG
}

public abstract class ContentManager {
	private static bool content_init = false;
	protected SupportedAudio supported_audio;

	public string ContentRoot = "content/";

	this() {
		if (!content_init) {
			Logger.Debug("ContentManagerWarmup: Starting warmup...");
			DerelictSDL2Mixer.load();
			SDL_Init(SDL_INIT_AUDIO);

			if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 1024) == -1) {
				const(char)* err = Mix_GetError();
				throw new Exception(Format("{0}", err));
			}

			int inited=Mix_Init(MIX_INIT_FLAC);
			if ((inited&MIX_INIT_FLAC) > 0) {
				supported_audio |= inited;
				Logger.Debug("ContentManagerWarmup: FLAC support initiated successfully.");
			} else {
				const(char)* err = Mix_GetError();
				Logger.Warn(Format("ContentManagerWarmup: FLAC support initiated failed. {0}", err));
			}
			inited=Mix_Init(MIX_INIT_MOD);
			if ((inited&MIX_INIT_MOD) > 0) {
				supported_audio |= inited;
				Logger.Debug("ContentManagerWarmup: MOD support initiated successfully.");
			} else {
				const(char)* err = Mix_GetError();
				Logger.Warn(Format("ContentManagerWarmup: MOD support initiated failed. {0}", err));
			}
			inited=Mix_Init(MIX_INIT_MP3);
			if ((inited&MIX_INIT_MP3) > 0) {
				supported_audio |= inited;
				Logger.Debug("ContentManagerWarmup: MP3 support initiated successfully.");
			} else {
				const(char)* err = Mix_GetError();
				Logger.Warn(Format("ContentManagerWarmup: MP3 support initiated failed. {0}", err));
			}
			inited=Mix_Init(MIX_INIT_OGG);
			if ((inited&MIX_INIT_OGG) > 0) {
				supported_audio |= inited;
				Logger.Debug("ContentManagerWarmup: OGG support initiated successfully.");
			} else {
				const(char)* err = Mix_GetError();
				Logger.Warn(Format("ContentManagerWarmup: OGG support initiated failed. {0}", err));
			}
			content_init = true;
			Logger.Debug("ContentManager initialized...");
		}
	}

	public abstract Texture2D LoadTexture(string name);
	public abstract Data LoadText(string name);
	public abstract Font LoadFont(string name);
	//public abstract Sound LoadSound(string name);
	//public abstract Music LoadMusic(string name);
	//public abstract Audio LoadAudio(string name);
}

public class PPCContentManager : ContentManager {

	this() {
		super();
		// Setup PPC content factories.
		ppc.SetupBaseFactories();
	}

	public override Texture2D LoadTexture(string name) {
		try {
			ppc.Image i = cast(ppc.Image)ppc.ContentManager.Load(this.ContentRoot~name~".ppc");
			if (i is null) throw new Exception("Could not find "~this.ContentRoot~name~".ppc");
			TextureImg img = new TextureImg(cast(int)i.Width, cast(int)i.Height, i.Colors);
			return new GlTexture2D(img);
		} catch (Exception ex) {
			Logger.Debug("{0}", ex.message);
			return null;
		}
	}

	public override Data LoadText(string name) {
		return null;
	}
	
	public override Font LoadFont(string name) {
		throw new Exception("Fonts not implemented in libppc yet!");
	}

	/*public override Sound LoadSound(string name) {
		throw new Exception("Audio not implemented in libppc yet!");
	}

	public override Music LoadMusic(string name) {
		throw new Exception("Audio not implemented in libppc yet!");
	}

	public override Audio LoadAudio(string name) {
		throw new Exception("Audio not implemented in libppc yet!");
	}*/
}

public class RawContentManager : ContentManager {

	this() {
		super();
	}

	public override Texture2D LoadTexture(string name) {
		/*auto f = IMG_Load((this.ContentRoot~name).ptr);
		if (f is null) throw new Exception("Could not load " ~ name);
		TextureImg img = new TextureImg(f);
		//TODO: Return VkTexture2D when vulkan support is implemented.
		return new GlTexture2D(img);*/
		throw new Exception("Loading textures via RawContentManger is unsupported currently.");
	}

	public override Data LoadText(string name) {
		return null;
	}
	
	public override Font LoadFont(string name) {
		return null;
	}

	/*public override Sound LoadSound(string name) {
		return null;
	}

	public override Music LoadMusic(string name) {
		Mix_Music* m = Mix_LoadMUS((this.ContentRoot~name).ptr);
		if (m is null) {
			const(char)* err = Mix_GetError();
			throw new Exception(Format("{0}", err));
		}
		return new Music(m);
	}

	public override Audio LoadAudio(string name) {
		Mix_Chunk* m = Mix_LoadWAV((this.ContentRoot~name).ptr);
		if (m is null) {
			const(char)* err = Mix_GetError();
			throw new Exception(Format("{0}", err));
		}
		return null;
	}*/
}