module polyplex.core.content.contentmanager;
import polyplex.core.content.textures;
import polyplex.core.content.gl;
import polyplex.core.content.vk;
import polyplex.core.content.font;
import polyplex.core.content.data;
import polyplex.utils.logging;
import polyplex.utils.strutils;
import polyplex.core.audio;

static import ppct = ppc.types;
import ppc.backend.loaders.ppc;

import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.sdl;

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

	public T Load(T)(string name) if (is(T : SoundEffect)) {
		Logger.Debug("Loading {0}...", name);
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		return new SoundEffect(ppct.Audio(ppc.data));
	}

	public T Load(T)(string name) if (is(T : Texture2D)) {
		Logger.VerboseDebug("Loading {0}...", name);
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		auto imgd = ppct.Image(ppc.data);
		TextureImg img = new TextureImg(cast(int)imgd.width, cast(int)imgd.height, imgd.pixelData, name);
		return new GlTexture2D(img);
	}

	import polyplex.core.render.gl.shader;
	import polyplex.core.render : ShaderCode;

	public T Load(T)(string name) if (is(T : GLShader)) {
		Logger.Debug("Loading {0}...", name);
		PPC ppc = PPC(this.ContentRoot~name~".ppc");
		auto shd = ppct.Shader(ppc.data);
		ShaderCode sc = new ShaderCode();
		foreach(k, v; shd.shaders) {
			if (k == ppct.ShaderType.Vertex) {
				sc.Vertex = v.toString;
			}
			if (k == ppct.ShaderType.Fragment) {
				sc.Fragment = v.toString;
			}
			if (k == ppct.ShaderType.Geometry) {
				sc.Geometry = g.toString;
			}
		}
		return new GLShader(sc);
	}
}