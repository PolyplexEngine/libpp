module ppsl.tokens;
enum Tokens {
	Unrecognized,
	EOF,
	Whitespace,

	StStartStatement,
	StEndStatement,
	StEnd,

	KwTechnique,
	KwGLSL,
	KwPreAttrib,

	KwSelect,
	KwVertex,
	KwFragment,
	KwTotal,
	
	KwHdShader,
	KwHdVersion,
	KwHdName,
	KwHdAttribs,
	KwHdVertex,
	KwHdFragment,

	Identifier,
	ConstDecimal,
	GlIn,
	GlOut,
	GlInOut,
	GlUniform,
	GlPrecision,
	GlHighp,
	GlReturn,

	GlVoid,
	GlFloat,
	GlVec2,
	GlVec3,
	GlVec4,
	GlMat,
	GlMat2x2,
	GlMat2x3,
	GlMat2x4,
	GlMat3x2,
	GlMat3x3,
	GlMat3x4,
	GlMat4x2,
	GlMat4x3,
	GlMat4x4,



}

struct TokenWord {
	string Word;
	int Length;
	Tokens Type;
}

class Token {
	TokenWord Word;
	string Content;
}

private static TokenWord defineToken(string name, Tokens type) {
	return TokenWord(name, cast(int)name.length, type);
}

public static TokenWord[] WORDS = [
	defineToken(" \t\r\n", Tokens.Whitespace),
	defineToken("{", Tokens.StStartStatement),
	defineToken("}", Tokens.StEndStatement),
	defineToken(";", Tokens.StEnd),
	defineToken("technique", Tokens.KwTechnique),
	defineToken("version", Tokens.KwTechnique),
	defineToken("glsl", Tokens.KwGLSL),
	defineToken("cg", Tokens.KwGLSL),
	defineToken("name", Tokens.KwHdName),
	defineToken("select", Tokens.KwSelect),
	defineToken("vertex", Tokens.KwVertex),
	defineToken("fragment", Tokens.KwFragment),
	defineToken("total", Tokens.KwTotal),
	defineToken("preattrib", Tokens.KwPreAttrib),
	//Graphics Language
	defineToken("in", Tokens.GlIn),
	defineToken("out", Tokens.GlOut),
	defineToken("inout", Tokens.GlInOut)//,
	//defineToken()
];
