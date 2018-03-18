#version 130
in vec3 ppPosition;
in vec2 ppTexcoord;
in vec4 ppColor;

uniform mat4 ppProjection;

out vec4 exColor;
out vec2 exTexcoord;

void main(void) {
	gl_Position = ppProjection * vec4(ppPosition.xy, 0.0, 1.0);
	exTexcoord = ppTexcoord;
	exColor = ppColor;
}