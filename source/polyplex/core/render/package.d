module polyplex.core.render;
public import polyplex.core.render.camera;
public import polyplex.core.render.shapes;
public import polyplex.core.render.common;
public import polyplex.core.render.enums;

// If OpenGL is chosen as a backend, import opengl
version(OpenGL) {
	public import polyplex.core.render.gl;
}

version(Vulkan) {
	public import polyplex.core.render.vk;
}