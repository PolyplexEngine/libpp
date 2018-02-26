module polyplex.core.render.vk.shader;
import polyplex.core.render;
import derelict.sdl2.sdl;
import derelict.vulkan;
import polyplex.math;
import polyplex.core.render;

class VkShader : Shader {
	public override void Attach() {

	}
	public override void Detach() {

	}
	public override void SetUniform(int location, float value) {

	}
	public override void SetUniform(int location, Vector2 value) {

	}
	public override void SetUniform(int location, Vector3 value) {

	}
	public override void SetUniform(int location, Vector4 value) {

	}
	public override void SetUniform(int location, int value) {

	}
	public override void SetUniform(int location, Vector2i value) {

	}
	public override void SetUniform(int location, Vector3i value) {

	}
	public override void SetUniform(int location, Vector4i value) {

	}
	
	public override uint GetUniform(string name) { return -1; }
	
	public override bool HasUniform(string name) {
		auto u = GetUniform(name);
		if (u == -1) return false;
		return true;
	}

}