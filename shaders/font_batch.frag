#version 330

precision highp float;

uniform sampler2D ppTexture;
in vec4 exColor;
in vec2 exTexcoord;
out vec4 outColor;

void main(void) {
	vec4 tex_col = vec4(1.0, 1.0, 1.0, texture2D(ppTexture, exTexcoord).r);
	outColor = exColor * tex_col;
}
