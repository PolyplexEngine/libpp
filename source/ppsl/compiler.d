module ppsl.compiler;
import ppsl.shader;

public abstract class Compiler {
	public abstract PPSLShader CompileSingle(string PPSLCode);
	public PPSLShaderCollection CompileCollection(string[] Code) {
		PPSLShaderCollection collection = new PPSLShaderCollection();
		foreach (string shader; Code) {
			collection.Add(CompileSingle(shader));
		}
		return collection;
	}
	public abstract OutputShader Transpile(PPSLShaderCollection collection);
}
