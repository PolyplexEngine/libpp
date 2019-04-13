#version 330
in vec3 ppPosition;
in vec2 ppTexcoord;
in vec4 ppColor;

uniform mat4 PROJECTION;

out vec4 exColor;
out vec2 exTexcoord;

void main(void) {
	gl_Position = PROJECTION * vec4(ppPosition.xyz, 1.0);
	exTexcoord = ppTexcoord;
	exColor = ppColor;
}
