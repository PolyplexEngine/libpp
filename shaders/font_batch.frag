#version 330

precision highp float;

uniform sampler2D ppTexture;
in vec4 exColor;
in vec2 exTexcoord;
out vec4 outColor;

void main(void) {
	vec4 tex_col = vec4(exColor.r, exColor.g, exColor.b, texture2D(ppTexture, exTexcoord).r*exColor.a);
	outColor = tex_col;
}
