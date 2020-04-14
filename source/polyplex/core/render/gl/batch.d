module polyplex.core.render.gl.batch;
import polyplex.core.render;
import polyplex.core.render.gl.shader;
import polyplex.core.render.gl.gloo;
import polyplex.core.render.gl.objects;
import polyplex.core.render.gl.renderbuf;
import polyplex.core.render.camera;
import polyplex.core.content.textures;
import polyplex.core.content.gl.textures;
import polyplex.core.content.font;
import polyplex.core.color;
import bindbc.opengl;
import bindbc.opengl.gl;
import polyplex.utils;
import polyplex.math;
import polyplex.utils.mathutils;
import std.utf;

import std.stdio;

/// Exception messages.
private enum : string {
	ErrorAlreadyStarted		= "SpriteBatch.Begin called more than once! Remember to end spritebatch sessions before beginning new ones.",
	ErrorNotStarted			= "SpriteBatch.Begin must be called before SpriteBatch.End.",
	ErrorNullTexture		= "Texture was null, please instantiate the texture before using it."
}

private struct SprBatchData {
	Vector3 position;
	Vector2 texCoord;
	Vector4 color;
}

private alias SBatchVBO = VertexBuffer!(SprBatchData, Layout.Interleaved);

public class SpriteBatch {
private:

	// Creation info
	enum UniformProjectionName = "PROJECTION";
	enum DefaultVert = import("sprite_batch.vert");
	enum DefaultFrag = import("sprite_batch.frag");
	enum DefaultVertFont = import("font_batch.vert");
	enum DefaultFragFont = import("font_batch.frag");
	static Shader defaultShader;
	static Shader defaultShaderFont;
	static Camera defaultCamera;
	static bool hasInitCompleted;

	// Previous shader, used in font rendering
	Shader prevShader;

	// State info
	int queued;
	bool hasBegun;
	bool swap;

	bool isRenderbuffer;

	// Buffer
	VertexArray 				elementVertexArray;
	Buffer 						elementBuffer;
	SprBatchData[6][16_384] 	elementArray;

	// OpenGL state info.
	SpriteSorting sortMode;
	Blending blendMode;
	Sampling sampleMode;
	RasterizerState rasterState;
	ProjectionState projectionState;
	Shader shader;

	// Textures
	Texture[] currentTextures;

	// Viewport
	Matrix4x4 viewProjectionMatrix;

	// Functions
	void setBlendState(Blending state) {
		switch(state) {
			case Blending.Additive:
				GL.BlendFunc(GL.SourceAlpha, GL.One);
				GL.BlendFunc(GL.SourceAlpha, GL.One);
				break;
			case Blending.AlphaBlend:
				GL.BlendFunc(GL.One, GL.OneMinusSourceColor);
				GL.BlendFunc(GL.One, GL.OneMinusSourceAlpha);
				break;
			case Blending.NonPremultiplied:
				GL.BlendFunc(GL.SourceColor, GL.OneMinusSourceColor);
				GL.BlendFunc(GL.SourceAlpha, GL.OneMinusSourceAlpha);
				break;
			default:
				GL.BlendFunc(GL.One, GL.Zero);
				break;
		}
	}

	void setProjectionState(ProjectionState state) {
		projectionState = state;
	}

	void setRasterizerState(RasterizerState state) {
		if (state.ScissorTest) GL.Enable(Capability.ScissorTest);
		if (state.MSAA) GL.Enable(Capability.Multisample);
		if (state.SlopeScaleBias > 0) GL.Enable(Capability.PolygonOffsetFill); 

		if (state.DepthTest) {
			GL.Enable(Capability.DepthTesting);
			GL.DepthFunc(GL.Less);
		}

		if (state.BackfaceCulling) {
			GL.Enable(Capability.CullFace);
			GL.CullFace(GL.Front);
		}
	}

	void resetRasterizerState() {
		GL.Disable(Capability.ScissorTest);
		GL.Disable(Capability.Multisample);
		GL.Disable(Capability.PolygonOffsetFill);
		GL.Disable(Capability.DepthTesting);
		GL.Disable(Capability.CullFace);
	}

	void setSamplerState(Sampling state) {
		switch(state) {
			case state.PointWrap:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
				break;
			case state.PointClamp:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.ClampToEdge);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.ClampToEdge);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
				break;
			case state.PointMirror:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.MirroredRepeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.MirroredRepeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
				break;
			case state.LinearWrap:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Linear);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Linear);
				break;
			case state.LinearClamp:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.ClampToEdge);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.ClampToEdge);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Linear);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Linear);
				break;
			case state.LinearMirror:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.MirroredRepeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.MirroredRepeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Linear);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Linear);
				break;
			default:
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapS, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.WrapT, GL.Repeat);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
				GL.SetTextureParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
				break;
		}
	}

	void addVertex(int offset, float x, float y, float r, float g, float b, float a, float u, float v, float depth) {
		this.elementArray[queued][offset].position = Vector3(x, y, depth);
		this.elementArray[queued][offset].texCoord = Vector2(u, v);
		this.elementArray[queued][offset].color = Vector4(r, g, b, a);
	}

	bool checkFlush(Texture[] textures) {

		// Throw exception if texture isn't instantiated.
		if (textures is null || textures.length == 0) throw new Exception(ErrorNullTexture);

		// Flush batch if needed, then update texture.
		if (currentTextures != textures || queued+1 >= elementArray.length) {
			if (currentTextures !is null || textures.length > 0) Flush();
			currentTextures = textures;
			return true;
		}
		return false;
	}

	void render() {
		// Skip out of nothing to render.
		if (queued == 0) return;

		// Bind vertex array.
		elementVertexArray.Bind();

		// Bind buffer
		elementBuffer.Bind(BufferType.Vertex);

		// Refill data
		elementBuffer.SubData(0, SprBatchData.sizeof*(queued*6), elementArray.ptr);

		// Setup attribute pointers.
		elementVertexArray.EnableArray(0);
		elementVertexArray.EnableArray(1);
		elementVertexArray.EnableArray(2);
		elementVertexArray.AttribPointer(0, 3, GL_FLOAT, GL_FALSE, SprBatchData.sizeof, cast(void*)SprBatchData.position.offsetof);
		elementVertexArray.AttribPointer(1, 2, GL_FLOAT, GL_FALSE, SprBatchData.sizeof, cast(void*)SprBatchData.texCoord.offsetof);
		elementVertexArray.AttribPointer(2, 4, GL_FLOAT, GL_FALSE, SprBatchData.sizeof, cast(void*)SprBatchData.color.offsetof);

		// TODO: Optimize rendering routine.

		// Attach everything else and render.
		shader.Attach();
		if (currentTextures !is null) {
			foreach(i, currentTexture; currentTextures) {
				currentTexture.Bind(TextureType.Tex2D);
				currentTexture.AttachTo(cast(int)i);
			}
		}
		setSamplerState(sampleMode);
		setBlendState(blendMode);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		shader.SetUniform(shader.GetUniform(UniformProjectionName), viewProjectionMatrix);

		GL.DrawArrays(GL.Triangles, 0, queued*6);

		if (currentTextures !is null) {
			foreach(currentTexture; currentTextures) {
				currentTexture.Bind(TextureType.Tex2D);
				currentTexture.AttachTo(0);
			}
		}

	}
	
	void draw(T, Y)(int width, int height, T pos, Y cutout, float rotation, Vector2 origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) if (IsRectangleT!T && IsRectangleT!Y) {
		float x1, y1;
		float x2, y2;
		float x3, y3;
		float x4, y4;

		static import std.math;
		float scaleX = cast(float)pos.Width/cast(float)width;
		float scaleY = cast(float)pos.Height/cast(float)height;
		float cx = origin.X*scaleX;
		float cy = origin.Y*scaleY;

		if (rotation != 0) {

			//top left
			float p1x = -cx;
			float p1y = -cy;

			//top right
			float p2x = pos.Width - cx;
			float p2y = -cy;

			//bottom right
			float p3x = pos.Width - cx;
			float p3y = pos.Height - cy;

			//bottom left
			float p4x = -cx;
			float p4y = pos.Height - cy;

			// Respect OffsetOrigin

			// TODO: Make OffsetOrigina a thing again?
			// if (!OffsetOrigin) {
			// }
			cx = 0;
			cy = 0;

			//Rotation sine and co-sine
			float cos = std.math.cos(rotation);
			float sin = std.math.sin(rotation);
			x1 = pos.X + (cos * p1x - sin * p1y) + cx;
			y1 = pos.Y + (sin * p1x + cos * p1y) + cy;

			x2 = pos.X + (cos * p2x - sin * p2y) + cx;
			y2 = pos.Y + (sin * p2x + cos * p2y) + cy;

			x3 = pos.X + (cos * p3x - sin * p3y) + cx;
			y3 = pos.Y + (sin * p3x + cos * p3y) + cy;

			x4 = pos.X + (cos * p4x - sin * p4y) + cx;
			y4 = pos.Y + (sin * p4x + cos * p4y) + cy;
		} else {
			// Respect OffsetOrigin

			// TODO: Make OffsetOrigin a thing again?
			// if (OffsetOrigin) {
			// }
			cx = 0;
			cy = 0;
			
			x1 = pos.X-cx;
			y1 = pos.Y-cy;

			x2 = pos.X+pos.Width-cx;
			y2 = pos.Y-cy;
			
			x3 = pos.X+pos.Width-cx;
			y3 = pos.Y+pos.Height-cy;

			x4 = pos.X-cx;
			y4 = pos.Y+pos.Height-cy;
		}
		// Remove any edges in spritesheets/atlases by cutting a tiiiiiny portion away
		float pxx = 0.2f/cast(float)width;
		float pxy = 0.2f/cast(float)height;

		float u = ((cutout.X)/cast(float)width)+pxx;
		float u2 = ((cutout.X+cutout.Width)/cast(float)width)-pxx;
		if ((flip&SpriteFlip.FlipVertical)>0) {
			float ux = u;
			u = u2;
			u2 = ux;
		}

		float v = ((cutout.Y)/cast(float)height)+pxy;
		float v2 = ((cutout.Y+cutout.Height)/cast(float)height)-pxy;
		if ((flip&SpriteFlip.FlipHorizontal)>0) {
			float vx = v;
			v = v2;
			v2 = vx;
		}

		// TODO: FIX THIS CURSED CODE.
		if (isRenderbuffer) {
			float vx = v;
			v = v2;
			v2 = vx;
		}

		addVertex(0, x1, y1, color.Rf(), color.Gf(), color.Bf(), color.Af(), u,   v, -zlayer); // TOP LEFT
		addVertex(1, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2,  v, -zlayer), // TOP RIGHT
		addVertex(2, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u,  v2, -zlayer); // BOTTOM LEFT
		addVertex(3, x2, y2, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2,  v, -zlayer), // TOP RIGHT
		addVertex(4, x3, y3, color.Rf(), color.Gf(), color.Bf(), color.Af(), u2, v2, -zlayer); // BOTTOM RIGHT
		addVertex(5, x4, y4, color.Rf(), color.Gf(), color.Bf(), color.Af(), u,  v2, -zlayer); // BOTTOM LEFT
		queued++;
	}

	/// Get matrix.
	Matrix4x4 defaultMultMatrices(Matrix4x4 mvpMatrix) {
		switch(projectionState) {
			case ProjectionState.Perspective:
				return defaultCamera.ProjectPerspective(Renderer.Window.ClientBounds.Width, 90f, Renderer.Window.ClientBounds.Height) * mvpMatrix;
			default:
				return defaultCamera.ProjectOrthographic(Renderer.Window.ClientBounds.Width, Renderer.Window.ClientBounds.Height) * mvpMatrix;
		}
	}

public:

	this() {
		elementVertexArray = new VertexArray();
		elementVertexArray.Bind();
		elementBuffer = new Buffer();
		elementBuffer.Bind(BufferType.Vertex);
		elementBuffer.Data(elementArray.sizeof, elementArray.ptr, BufferUsage.DynamicDraw);
		Logger.Warn("Some OpenGL features are not implemented yet, namely DepthStencilState, RasterizerState and some SpriteSortModes.");
	}

	/// Initialize sprite batch
	static void InitializeSpritebatch() {
		if (!hasInitCompleted) hasInitCompleted = !hasInitCompleted;
		else return;

		defaultShader = new Shader(new ShaderCode(DefaultVert, DefaultFrag));
		defaultShaderFont = new Shader(new ShaderCode(DefaultVertFont, DefaultFragFont));
		defaultCamera = new Camera2D(Vector2(0, 0));
		defaultCamera.Update();
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	void Begin() {
		Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.LinearClamp, RasterizerState.Default, defaultShader, defaultCamera);
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	void Begin(SpriteSorting sortMode, Blending blendState, Sampling sampleState, RasterizerState rasterState, Shader shader, Matrix4x4 matrix) {
		if (hasBegun) throw new Exception(ErrorAlreadyStarted);
		hasBegun = true;
		this.sortMode = sortMode;
		this.blendMode = blendState;
		this.sampleMode = sampleState;
		this.blendMode = blendState;
		this.viewProjectionMatrix = matrix;
		this.shader = shader;

		this.rasterState = rasterState;
		setRasterizerState(rasterState);

		this.shader = shader !is null ? shader : defaultShader;
		this.currentTextures = null;
		this.queued = 0;
	}

	/**
		Begin begins the spritebatch, setting up sorting modes, blend states and sampling.
		Begin also attaches a custom shader (if chosen) and sets the camera/view matrix.
	*/
	void Begin(SpriteSorting sortMode, Blending blendState, Sampling sampleState, RasterizerState rasterState, Shader shader, Camera camera) {
		Camera cam = camera !is null ? camera : defaultCamera;
		cam.Update();
		Begin(sortMode, blendState, sampleState, rasterState, shader, defaultMultMatrices(cam.Matrix));
	}

	void Begin(SpriteSorting sortMode, Blending blendState, Sampling sampleState, RasterizerState rasterState, ProjectionState pstate, Shader shader, Camera camera) {
		setProjectionState(pstate);
		Begin(sortMode, blendState, sampleState, rasterState, shader, camera);
	}

	void Draw(T, Y)(Texture2D texture, T pos, Y cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) if (IsRectangleT!T && IsRectangleT!Y) {
		Draw(texture, pos, cutout, 0f, Vector2(-1, -1), color, flip, zlayer);
	}

	void Draw(T, Y)(Texture2D texture, T pos, Y cutout, float rotation, Vector2 origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) if (IsRectangleT!T && IsRectangleT!Y) {
		isRenderbuffer = false;
		checkFlush([(cast(GlTexture2D)texture).GLTexture]);
		draw(texture.Width, texture.Height, pos, cutout, rotation, origin, color, flip, zlayer);
	}

	void Draw(T, Y)(polyplex.core.render.Framebuffer buffer, T pos, Y cutout, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) if (IsRectangleT!T && IsRectangleT!Y) {
		Draw(buffer, pos, cutout, 0f, Vector2(-1, -1), color, flip, zlayer);
	}

	void Draw(T, Y)(polyplex.core.render.Framebuffer buffer, T pos, Y cutout, float rotation, Vector2 origin, Color color, SpriteFlip flip = SpriteFlip.None, float zlayer = 0f) if (IsRectangleT!T && IsRectangleT!Y) {
		isRenderbuffer = true;
		checkFlush(buffer.OutTextures);
		draw(buffer.Width, buffer.Height, pos, cutout, rotation, origin, color, flip, zlayer);
	}

	/**
		Begin string rendering
	*/
	void BeginString(SpriteFont font, Shader textShader = null) {
		isRenderbuffer = false;
		prevShader = this.shader;

		// Support custom font shaders.
		checkFlush([(cast(GlTexture2DImpl!(GL_RED, 1))font.getTexture()).GLTexture]);
		this.shader = textShader !is null ? textShader : defaultShaderFont;
	}

	/**
		End string rendering
	*/
	void EndString() {
		Flush();

		// Revert back to the previous shader.
		this.shader = prevShader;
	}

	/**
		Draws a single character, returns the spot for the next character to be drawn

		Notice: You'll have to execute BeginString before rendering a character and EndString after you're done rendering characters
		Otherwise the wrong shaders will be used, etc.
	*/
	Vector2 DrawChar(SpriteFont font, dchar character, Vector2 position, Color color, float scale = 1, float zlayer = 0f) {

		auto info = font[character];
		if (info is null) return Vector2.NaN;

		// Position to draw
		float posX = cast(int)(position.X + info.bearing.x * scale);
		float posY = cast(int)(((position.Y-info.size.y) + cast(int)(info.size.y - info.bearing.y)+font.BaseCharSize.Y)*scale);
		Rectangle currentRectangle = Rectangle(
			posX, 
			posY,
			info.size.x*scale, 
			info.size.y*scale);

		// Clipping for character
		Rectangle clipRectangle = Rectangle(info.origin.x, info.origin.y, info.size.x, info.size.y);

		// Send to rendering
		draw(font.TexSize.X, font.TexSize.Y, currentRectangle, clipRectangle, 0f, Vector2(0, 0), color, SpriteFlip.None, zlayer);

		// Bitshift 6 times to get value in pixels
		return Vector2(position.X+((info.advance.x >> 6) * scale), position.Y);
	}

	/**
		Draws a string

		Allows special formatting rules:
			[c=(HEX)] to change the color
			[c=clear] to clear colors
	*/
	void DrawString(SpriteFont font, dstring text, Vector2 position, Color color, float scale = 1f, float zlayer = 0f, Shader textShader = null) {
		import std.conv : to;
		Color startColor = color;
		Color currentColor = startColor;

		BeginString(font, textShader);

			Vector2 next = position;
			size_t i = 0;
			size_t line = 0;
			while(i < text.length) {

				if (text[i] == '\n') {
					line++;
					i++;
					next.X = position.X;
					next.Y += font.BaseCharSize.Y+ (font.BaseCharSize.Y/2);
					continue;
				}

				if (i < text.length-4) {

					// Check if we're in a formatting rule
					if (text[i] == '[' && text[i+2] == '=') {
						switch(text[i+1]) {
							// Color formatting rule
							case 'c':
								// Move the 4 characters of the formatting rule on
								i += 3;
								string fmtColorStr;

								// Fetch all the assignment data untill we hit the end
								while (text[i] != ']') {
									fmtColorStr ~= text[i++];
								}

								// Skip the last closing bracket
								i++;
								
								// If the command was to clear color, clear it.
								if (fmtColorStr == "clear") {
									currentColor = startColor;
									break;
								}

								// Break out if the color data length isn't an even number
								if (fmtColorStr.length % 2 != 0) break;

								// pushback value to allow shorter hex values
								size_t pushBack = 8*(3-((fmtColorStr.length/2)-1));

								// The output color value, if no alpha was chosen then automatically insert 255.
								uint colorValue = ((fmtColorStr.length/2) < 4 ? 0x000000FF : 0x00) | (fmtColorStr.to!uint(16) << pushBack);

								currentColor = new Color(colorValue);
								break;

							// Wasn't a formatting rule, nevermind
							default: break;
						}
					}
				}

				// Draw a character
				dchar c = cast(dchar)text[i];
				next = DrawChar(font, c, next, currentColor, scale, zlayer);

				// Next character
				i++;
			}

		EndString();
	}

	/**
		Draws a string

		Allows special formatting rules:
			[c=(HEX)] to change the color
			[c=clear] to clear colors
	*/
	void DrawString(SpriteFont font, string utf8text, Vector2 position, Color color, float scale = 1f, float zlayer = 0f, Shader textShader = null) {
		dstring text = toUTF32(utf8text);
		DrawString(font, text, position, color, scale, zlayer, shader);
	}

	/**
		Draws a string

		Allows special formatting rules:
			[c=(HEX)] to change the color
			[c=clear] to clear colors
	*/
	void DrawString(SpriteFont font, wstring utf16text, Vector2 position, Color color, float scale = 1f, float zlayer = 0f, Shader textShader = null) {
		dstring text = toUTF32(utf16text);
		DrawString(font, text, position, color, scale, zlayer, shader);
	}
	
	void Flush() {
		render();
		currentTextures = [];
		queued = 0;
	}

	void SwapChain() {

	}

	void End() {
		hasBegun = false;
		Flush();
		resetRasterizerState();
	}
}