module polyplex.core.content.contentmanager;
import polyplex.core.content.textures;
import polyplex.core.content.gl;
import polyplex.core.content.vk;
import polyplex.core.content.font;
import polyplex.core.content.data;
import polyplex.utils.logging;
import polyplex.utils.strutils;
import polyplex.core.audio;

import polyplex.core.render : Shader, ShaderCode;
import polyplex.core.render.gl.shader;

static import ppct = ppc.types;
import ppc.backend.loaders.ppc;
import ppc.backend.cfile;
import bindbc.sdl;

public enum SupportedAudio {
	OGG
}

public class ContentManager {
	private static bool content_init = false;
	protected SupportedAudio supported_audio;

	public string ContentRoot = "content/";

	this() {
		if (!content_init) {
			Logger.Debug("ContentManagerWarmup: Starting warmup...");
			
			// TODO: Configure OpenAL
			
			content_init = true;
			Logger.Debug("ContentManager initialized...");
		}
	}

	T loadLocal(T)(string name) if (is(T : SoundEffect)) {
		return new SoundEffect(ppct.Audio(loadFile(name)));
	}

	public T Load(T)(string name) if (is(T : SoundEffect)) {
		// Load raw file if instructed to.
		if (name[0] == '!') return loadLocal!T(name[1..$]);

		// Otherwise load PPC file
		PPC ppc = PPC(loadFile(this.ContentRoot~name~".ppc"));
		return new SoundEffect(ppct.Audio(ppc.data));
	}

	T loadLocal(T)(string name) if (is(T : Music)) {
		return new Music(ppct.Audio(loadFile(name)));
	}

	public T Load(T)(string name) if (is(T : Music)) {
		// Load raw file if instructed to.
		if (name[0] == '!') return loadLocal!T(name[1..$]);

		// Otherwise load PPC file
		PPC ppc = PPC(loadFile(this.ContentRoot~name~".ppc"));
		return new Music(ppct.Audio(ppc.data));
	}

	T loadLocal(T)(string name) if (is(T : Texture2D)) {
		auto imgd = ppct.Image(loadFile(name));
		TextureImg img = new TextureImg(cast(int)imgd.width, cast(int)imgd.height, imgd.pixelData, name);
		return new GlTexture2D(img);
	}

	public T Load(T)(string name) if (is(T : Texture2D)) {
		// Load raw file if instructed to.
		if (name[0] == '!') return loadLocal!T(name[1..$]);

		// Otherwise load PPC file
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		auto imgd = ppct.Image(ppc.data);
		TextureImg img = new TextureImg(cast(int)imgd.width, cast(int)imgd.height, imgd.pixelData, name);
		return new GlTexture2D(img);
	}

	T loadLocal(T)(string name) if (is(T : SpriteFont)) {
		auto tface = ppct.TypeFace(loadFile(name));
		return new SpriteFont(tface);
	}

	public T Load(T)(string name) if (is(T : SpriteFont)) {
		// Load raw file if instructed to.
		if (name[0] == '!') return loadLocal!T(name[1..$]);

		// Otherwise load PPC file
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		auto tface = ppct.TypeFace(ppc.data);
		return new SpriteFont(tface);
	}

	public T Load(T)(string name) if (is(T : Shader)) {
		// Shaders can't be loaded locally
		if (name[0] == '!') throw new Exception("Shaders cannot be loaded rawly, please use ppcc to convert to PSGL");

		// Otherwise load PPC file
		Logger.Debug("Loading {0}...", name);
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		auto shd = ppct.Shader(ppc.data);
		ShaderCode sc = new ShaderCode();
		Logger.VerboseDebug("Shader Count: {0}", shd.shaders.length);
		foreach(k, v; shd.shaders) {
			if (k == ppct.ShaderType.Vertex) {
				sc.Vertex = v.toString;
				Logger.VerboseDebug("Vertex Shader:\n{0}", sc.Vertex);
			}
			if (k == ppct.ShaderType.Fragment) {
				sc.Fragment = v.toString;
				Logger.VerboseDebug("Fragment Shader:\n{0}", sc.Fragment);
			}
			if (k == ppct.ShaderType.Geometry) {
				sc.Geometry = v.toString;
			}
		}
		return new GLShader(sc);
	}
}