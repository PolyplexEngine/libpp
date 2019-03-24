module ppsl.cg.compiler;
import ppsl.compiler;
import ppsl.shader;
import ppsl.errors;

public class CgCompiler : Compiler {
	public override PPSLShader CompileSingle(string PPSLCode) {
		throw ERROR_CG_UNSUPPORTED;
	}

	public override OutputShader Transpile(PPSLShaderCollection collection) {
		throw ERROR_CG_UNSUPPORTED;
	}
}