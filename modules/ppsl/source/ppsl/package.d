module ppsl;
import ppsl.cg;
import ppsl.glsl;
import ppsl.shader;
import ppsl.tokens;
import ppsl.parser;
import ppsl.compiler;

public class PPSL {
	private PPSLCompiler target_compiler;
	private Compiler compiler;

	public this(PPSLCompiler target) {
		this.target_compiler = target;
	}
}