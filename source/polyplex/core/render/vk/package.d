//deprecated("Polyplex-Vulkan is not in a ready state yet. Please see Polyplex-OpenGL")
module polyplex.core.render.vk;
import polyplex.core.render;
import polyplex.core.render.vk.vk;
import polyplex.core.rendersurface;
import polyplex.core.color;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.vulkan.vulkan;

import std.stdio;

public import polyplex.core.render.vk.shader;

public class VkRenderer : BackendRenderer {

	this(RenderSurface parent) { super(parent); }
	
	public override void Init(SDL_Window* w) {
		writeln("Heyo!");
	}

	public override void ClearColor(Color color) {

	}

	public override void ClearDepth() {
		
	}

	public override void AdjustViewport() {
		
	}

	public override void SwapBuffers() {
		
	}
		
	public override @property VSyncState VSync() {
		return VSyncState.VSync;
	}

	public override @property void VSync(VSyncState state) {
	}

	public override Shader CreateShader(ShaderCode code) {
		return null;
	}
}
