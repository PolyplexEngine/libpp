//deprecated("Polyplex-Vulkan is not in a ready state yet. Please see Polyplex-OpenGL")
module polyplex.core.render.vk;
import polyplex.core.render;
import polyplex.core.render.vk.vk;
import polyplex.core.window;
import polyplex.core.color;
import polyplex.math;

import derelict.sdl2.sdl;
import derelict.vulkan.vulkan;

public import polyplex.core.render.vk.shader;

public class VkRenderer : Renderer {
	public override void Init(SDL_Window* w) {
		ApplicationInfo info = new ApplicationInfo("AAAA", "EEEEE", new Version(), new Version(), new Version());
		InstanceCreateInfo cinfo = info.CreateInfo;
		
	}

	public override void ClearColor(Color color) {

	}

	public override void ClearDepth() {
		
	}

	public override void SetViewport(Rectangle size) {

	}

	public override void SwapBuffers() {
		
	}

	protected override void UpdateViewport(int width, int height) {
		
	}

	public override Shader CreateShader(ShaderCode code) {
		return null;
	}
}