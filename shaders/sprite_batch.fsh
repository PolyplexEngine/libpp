#version 130

precision highp float;

uniform sampler2D ppTexture;
in vec4 exColor;
in vec2 exTexcoord;
out vec4 outColor;

void main(void) {
	vec4 tex_col = texture2D(ppTexture, exTexcoord);
	outColor = exColor * tex_col;
}