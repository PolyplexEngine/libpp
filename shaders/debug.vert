#version 130
in vec2 ppPosition;
in vec4 ppColor;

uniform mat4 ppProjection;

out vec4 exColor;

void main(void) {
	gl_Position = ppProjection * vec4(ppPosition.xy, 0.0, 1.0);
	exColor = ppColor;
}