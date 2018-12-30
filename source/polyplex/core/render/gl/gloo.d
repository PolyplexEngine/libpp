module polyplex.core.render.gl.gloo;
public import bindbc.opengl;

private __gshared Buffer[GLenum]            boundBuffers;
private __gshared Texture[GLenum]           boundTextures;
private __gshared Framebuffer[GLenum]       boundFramebuffers;
private __gshared Sampler[GLenum]           boundSamplers;
private __gshared Renderbuffer              boundRenderbuffer;
private __gshared VertexArray               boundVertexArray;
//private __gshared AsyncQuery[GLenum]        boundAsyncQueries;
//private __gshared Pipeline[GLenum]          boundPipelines;
//private __gshared TransformFeedback[GLenum] boundTransformFeedbacks;

public @nogc:

enum Capability : GLenum {
    AlphaTesting        = GL_ALPHA_TEST,
    AutoNormal          = GL_AUTO_NORMAL,
    Blending            = GL_BLEND,
    ColorLogic          = GL_COLOR_LOGIC_OP,
    ColorMaterial       = GL_COLOR_MATERIAL,
    ColorSum            = GL_COLOR_SUM,
    ColorTable          = GL_COLOR_TABLE,
    Convolution1D       = GL_CONVOLUTION_1D,
    Convolution2D       = GL_CONVOLUTION_2D,
    CullFace            = GL_CULL_FACE,
    DepthTesting        = GL_DEPTH_TEST,
    Dithering           = GL_DITHER,
    Fog                 = GL_FOG,
    Histogram           = GL_HISTOGRAM,
    IndexLogic          = GL_INDEX_LOGIC_OP,
    Lighting            = GL_LIGHTING,
    LineSmooth          = GL_LINE_SMOOTH,
    LineStipple         = GL_LINE_STIPPLE,
    // TODO: Add a bunch of GL_MAP stuff

    MinMax              = GL_MINMAX,
    Multisample         = GL_MULTISAMPLE,
    Normalize           = GL_NORMALIZE,
    PointSmooth         = GL_POINT_SMOOTH,
    PointSprite         = GL_POINT_SPRITE,
    PolygonOffsetFill   = GL_POLYGON_OFFSET_FILL,
    PolygonOffsetLine   = GL_POLYGON_OFFSET_LINE,
    PolygonOffsetPoint  = GL_POLYGON_OFFSET_POINT,
    PolygonSmooth       = GL_POLYGON_SMOOTH,
    PolygonStipple      = GL_POLYGON_STIPPLE,

    ScissorTest         = GL_SCISSOR_TEST,
    StencilTest         = GL_STENCIL_TEST

}
/**
    Functions for OpenGL not attached to an object.
*/
class GL {
public:
    enum : GLenum {

        // Filters
        Nearest                     = GL_NEAREST,
        NearestMipmapNearest        = GL_NEAREST_MIPMAP_NEAREST,
        NearestMipmapLinear         = GL_NEAREST_MIPMAP_LINEAR,
        Linear                      = GL_LINEAR,
        LinearMipmapNearest         = GL_LINEAR_MIPMAP_NEAREST,
        LinearMipmapLinear          = GL_LINEAR_MIPMAP_LINEAR,

        // Swizzle
        Red                         = GL_RED,
        Green                       = GL_GREEN,
        Blue                        = GL_BLUE,
        Alpha                       = GL_ALPHA,

        // Wrap
        ClampToEdge                 = GL_CLAMP_TO_EDGE,
        ClampToBorder               = GL_CLAMP_TO_BORDER,
        MirroredRepeat              = GL_MIRRORED_REPEAT,
        Repeat                      = GL_REPEAT,

        // Draw modes
        Points                      = GL_POINTS,
        LineStrip                   = GL_LINE_STRIP,
        LineLoop                    = GL_LINE_LOOP,
        Lines                       = GL_LINES,
        LineStripAdjacency          = GL_LINE_STRIP_ADJACENCY,
        LinesAdjacency              = GL_LINES_ADJACENCY,
        TriangleStrip               = GL_TRIANGLE_STRIP,
        TriangleFan                 = GL_TRIANGLE_FAN,
        Triangles                   = GL_TRIANGLES,
        TriangleStripAdjacency      = GL_TRIANGLE_STRIP_ADJACENCY,
        TrianglesAdjacency          = GL_TRIANGLES_ADJACENCY
        
    }


static:
    /**
        Enables an OpenGL capability.
    */
    void Enable(Capability cap) {
        glEnable(cap);
    }

    /**
        Disables an OpenGL capability
    */
    void Disable(Capability cap) {
        glDisable(cap);
    }

    void DrawArrays(GLenum mode, GLint first, GLsizei count) {
        glDrawArrays(mode, first, count);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, GLint param) {
        glTexParameteri(target, pname, param);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, GLfloat param) {
        glTexParameterf(target, pname, param);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, GLint* param) {
        glTexParameteriv(target, pname, param);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, GLfloat* param) {
        glTexParameterfv(target, pname, param);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, const(GLint)* param) {
        glTexParameterIiv(target, pname, param);
    }

    /// 
    void SetTextureParameter(GLenum target, GLenum pname, const(GLuint)* param) {
        glTexParameterIuiv(target, pname, param);
    }

    /// 
    void BufferSubData(GLenum target, ptrdiff_t offset, ptrdiff_t size, void* data) {
        glBufferSubData(target, offset, size, data);
    }

    /// 
    void BufferData(GLenum target, ptrdiff_t size, void* data, GLenum usage) {
        glBufferData(target, size, data, usage);
    }
}


enum ObjectClass {
    Anything,
    Data,
    Texture
}

abstract class GLObject {
private:
    GLuint id;
public:
    /// Binds the object with default type
    abstract void Bind();

    /// Binds the object
    abstract void Bind(GLenum target);

    /// Unbinds the object
    abstract void Unbind();
}

/*
        ------ BUFFERS ------
*/

enum BufferUsage : GLenum {
    StreamDraw          = GL_STREAM_DRAW,
    StreamRead          = GL_STREAM_READ,
    StreamCopy          = GL_STREAM_COPY,
    StaticDraw          = GL_STATIC_DRAW,
    StaticRead          = GL_STATIC_READ,
    StaticCopy          = GL_STATIC_COPY,
    DynamicDraw          = GL_DYNAMIC_DRAW,
    DynamicRead          = GL_DYNAMIC_READ,
    DynamicCopy          = GL_DYNAMIC_COPY,
}

enum BufferType : GLenum {
    /// Vertex Attributes
    Vertex              = GL_ARRAY_BUFFER,

    /// Buffer Copy Source
    CopyRead            = GL_COPY_READ_BUFFER,

    /// Buffer Copy Destination
    CopyWrite           = GL_COPY_WRITE_BUFFER,

    /// Vertex Array Indices
    ElementAray         = GL_ELEMENT_ARRAY_BUFFER,

    /// Pixel Read Target
    PixelPack           = GL_PIXEL_PACK_BUFFER,

    /// Texture Data Source
    PixelUnpack         = GL_PIXEL_UNPACK_BUFFER,

    /// Texture Data Buffer
    Texture             = GL_TEXTURE_BUFFER,

    /// Uniform Block Storage
    Uniform             = GL_UNIFORM_BUFFER
}

class Buffer : GLObject {
private:
    GLenum boundTarget;

public:
    this() {
        glGenBuffers(1, &id);    
    }

    ~this() {
        glDeleteBuffers(1, &id);
    }

    /// Binds the buffer with default type
    override void Bind() {
        Bind(BufferType.Vertex);
    }

    /// Binds the buffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (target in boundBuffers && 
            boundBuffers[target] !is null && 
            boundBuffers[target].id == id) return;

        // Unbind from old position if needed.
        if (boundTarget != 0) Unbind();

        // Bind to new position.
        boundTarget = target;
        boundBuffers[boundTarget] = this;
        glBindBuffer(target, id);
    }

    /// Unbinds the buffer (binds buffer 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundTarget == 0) return;

        /// If another buffer is bound there, bail out.
        if (boundBuffers[boundTarget].id != id) return;

        /// Unbind target.
        glBindBuffer(boundTarget, 0);
        boundBuffers[boundTarget] = null;
        boundTarget = 0;
    }

    /// 
    void Data(ptrdiff_t size, void* data, GLenum usage) {
        if (boundTarget == 0) return;
        GL.BufferData(boundTarget, size, data, usage);
    }

    /// 
    void SubData(ptrdiff_t offset, ptrdiff_t size, void* data) {
        if (boundTarget == 0) return;
        GL.BufferSubData(boundTarget, offset, size, data);
    }

    /*
    /// glBufferStorage.
    void BufferStorage(GLenum target, ptrdiff_t size, void* data, GLbitfield flags) {
        Bind(target);
        glBufferStorage(target, size, data, flags);
    }
    
    /// Clear buffer data.
    void ClearBufferData(GLenum target, GLenum internalFormat, GLenum format, GLenum type, void* data) {
        Bind(target);
        glClearBufferData(target, internalFormat, format, type, data);
    }

    /// Clear buffer sub data.
    void ClearBufferSubData(GLenum target, GLenum internalFormat, ptrdiff_t offset, ptrdiff_t size, GLenum format, GLenum type, void* data) {
        Bind(target);
        glClearBufferSubData(target, internalFormat, offset, size, format, type, data);
    }

    /*void CopyBufferSubData(GLenum readtarget​, GLenum writetarget​, ptrdiff_t readoffset​, ptrdiff_t writeoffset​, ptrdiff_t size​) {
        Bind(readtarget​);
        CopyBufferSubData(readtarget​, writetarget​, readoffset​, writeoffset, size​);
    }*/
}



/*
        ------ TEXTURES ------
*/

enum TextureType : GLenum {
    /// 1D Texture
    Tex1D                   = GL_TEXTURE_1D,

    /// 2D Texture
    Tex2D                   = GL_TEXTURE_2D,

    /// 3D Texture
    Tex3D                   = GL_TEXTURE_3D,

    /// Array of 1D Textures
    Tex1DArray              = GL_TEXTURE_1D_ARRAY,

    /// Array of 2D Textures
    Tex2DArray              = GL_TEXTURE_2D_ARRAY,

    /// Rectangle Texture
    TexRectangle            = GL_TEXTURE_RECTANGLE,

    /// Cube Map
    TexCubeMap              = GL_TEXTURE_CUBE_MAP,

    /// Buffer
    TexBuffer               = GL_TEXTURE_BUFFER,

    /// Multisampled 2D Texture
    Tex2DMultisample        = GL_TEXTURE_2D_MULTISAMPLE,

    /// Array of Multisampled 2D Textures
    Tex2DMultisampleArray   = GL_TEXTURE_2D_MULTISAMPLE_ARRAY
}

enum TextureParameter : GLenum {

    /// 
    BaseLevel                   = GL_TEXTURE_BASE_LEVEL,
    
    /// 
    CompareFunc                 = GL_TEXTURE_COMPARE_FUNC,
    
    /// 
    CompareMode                 = GL_TEXTURE_COMPARE_MODE,
    
    /// 
    LODBias                     = GL_TEXTURE_LOD_BIAS,
    
    /// 
    MinFilter                   = GL_TEXTURE_MIN_FILTER,
    
    /// 
    MagFilter                   = GL_TEXTURE_MAG_FILTER,
    
    /// 
    MinLOD                      = GL_TEXTURE_MIN_LOD,
    
    /// 
    MaxLOD                      = GL_TEXTURE_MAX_LOD,
    
    /// 
    MaxLevel                    = GL_TEXTURE_MAX_LEVEL,
    
    /// 
    SwizzleR                    = GL_TEXTURE_SWIZZLE_R,
    
    /// 
    SwizzleG                    = GL_TEXTURE_SWIZZLE_G,
    
    /// 
    SwizzleB                    = GL_TEXTURE_SWIZZLE_B,
    
    /// 
    SwizzleA                    = GL_TEXTURE_SWIZZLE_A,
    
    /// 
    WrapS                       = GL_TEXTURE_WRAP_S,
    
    /// 
    WrapT                       = GL_TEXTURE_WRAP_T,
    
    /// 
    WrapR                       = GL_TEXTURE_WRAP_R
}

class Texture : GLObject {
private:
    GLenum boundTarget;

public:
    this() {
        glGenTextures(1, &id);
    }

    ~this() {
        glDeleteTextures(1, &id);
    }

    /// Binds the texture with default type
    override void Bind() {
        Bind(TextureType.Tex2D);
    }

    /// Binds the texture
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (target in boundTextures && 
            boundTextures[target] !is null && 
            boundTextures[target].id == id) return;

        // Unbind from old position if needed.
        if (boundTarget != 0) Unbind();

        // Bind to new position.
        boundTarget = target;
        boundTextures[boundTarget] = this;
        glBindTexture(target, id);
    }

    /// Unbinds the texture (binds texture 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundTarget == 0) return;

        /// If another texture is bound there, bail out.
        if (boundTextures[boundTarget].id != id) return;

        /// Unbind target.
        glBindTexture(boundTarget, 0);
        boundTextures[boundTarget] = null;
        boundTarget = 0;
    }

    /// 
    void AttachTo(GLenum textureid) {
        glActiveTexture(GL_TEXTURE0+textureid);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLint param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLfloat param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLint* param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLfloat* param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, const(GLint)* param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, const(GLuint)* param) {
        Bind(target);
        GL.SetTextureParameter(target, pname, param);
    }

    /// 
    void Image1D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const(GLvoid)* data) {
        glTexImage1D(target, level, internalFormat, width, border, format, type, data);
    }

    /// 
    void Image2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const(GLvoid)* data) {
        glTexImage2D(target, level, internalFormat, width, height, border, format, type, data);
    }

    /// 
    void Image2DMultisample(GLenum target, GLsizei samples, GLint internalFormat, GLsizei width, GLsizei height, GLboolean fixedSampleLocations) {
        glTexImage2DMultisample(target, samples, internalFormat, width, height, fixedSampleLocations);
    }

    /// 
    void Image3D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const(GLvoid)* data) {
        glTexImage3D(target, level, internalFormat, width, height, depth, border, format, type, data);
    }

    /// 
    void Image3DMultisample(GLenum target, GLsizei samples, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedSampleLocations) {
        glTexImage3DMultisample(target, samples, internalFormat, width, height, depth, fixedSampleLocations);
    }
}


/*
        ------ FRAMEBUFFERS ------
*/

enum FramebufferType : GLenum {
    /// A framebuffer which does multiple operations
    Multi           = GL_FRAMEBUFFER,

    /// Framebuffer that can be drawn to
    Drawing         = GL_DRAW_FRAMEBUFFER,

    /// Framebuffer that can be read from.
    Reading         = GL_READ_FRAMEBUFFER
}

class Framebuffer : GLObject {
private:
    GLenum boundTarget;

public:
    this() {
        glGenFramebuffers(1, &id);
    }

    ~this() {
        glDeleteFramebuffers(1, &id);
    }

    /// Binds the framebuffer with default type
    override void Bind() {
        Bind(FramebufferType.Multi);
    }

    /// Binds the framebuffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (target in boundFramebuffers && 
            boundFramebuffers[target] !is null && 
            boundFramebuffers[target].id == id) return;

        // Unbind from old position if needed.
        if (boundTarget != 0) Unbind();

        // Bind to new position.
        boundTarget = target;
        boundFramebuffers[boundTarget] = this;
        glBindFramebuffer(target, id);
    }

    /// Unbinds the framebuffer (binds framebuffer 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundTarget == 0) return;

        /// If another framebuffer is bound there, bail out.
        if (boundFramebuffers[boundTarget].id != id) return;

        /// Unbind target.
        glBindFramebuffer(boundTarget, 0);
        boundFramebuffers[boundTarget] = null;
        boundTarget = 0;
    }
    
    /// 
    void Renderbuffer(GLenum target, GLenum attachment, GLenum source, GLuint buffer) {
        Bind(target);
        glFramebufferRenderbuffer(target, attachment, source, buffer);
    }

    /// 
    void Texture(GLenum target, GLenum attachment, GLuint texture, GLint level) {
        Bind(target);
        glFramebufferTexture(target, attachment, texture, level);
    }

    /// 
    void Texture1D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level) {
        Bind(target);
        glFramebufferTexture1D(target, attachment, textarget, texture, level);
    }

    /// 
    void Texture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level) {
        Bind(target);
        glFramebufferTexture2D(target, attachment, textarget, texture, level);
    }

    /// 
    void Texture3D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint layer) {
        Bind(target);
        glFramebufferTexture3D(target, attachment, textarget, texture, level, layer);
    }

    /// 
    void TextureLayer(GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer) {
        Bind(target);
        glFramebufferTextureLayer(target, attachment, texture, level, layer);
    }
}

/*
        ------ RENDERBUFFERS ------
*/

class Renderbuffer : GLObject {
public:
    this() {
        glGenRenderbuffers(1, &id);
    }

    ~this() {
        glDeleteRenderbuffers(1, &id);
    }

    /// Binds the renderbuffer with default type
    override void Bind() {
        Bind(0);
    }

    /// Binds the renderbuffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundRenderbuffer is this) return;

        // Bind to new position.
        boundRenderbuffer = this;
        glBindRenderbuffer(GL_RENDERBUFFER, id);
    }

    /// Unbinds the renderbuffer (binds renderbuffer 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundRenderbuffer is null) return;

        /// If another renderbuffer is bound there, bail out.
        if (boundRenderbuffer !is this) return;

        /// Unbind target.
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        boundRenderbuffer = null;
    }

    /// 
    void Storage(GLenum internalFormat, GLsizei width, GLsizei height) {
        glRenderbufferStorage(GL_RENDERBUFFER, internalFormat, width, height);
    }

    /// 
    void StorageMultisample(GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height) {
        glRenderbufferStorageMultisample(GL_RENDERBUFFER, samples, internalFormat, width, height);
    }
}


/*
        ------ VERTEX ARRAYS ------
*/

class VertexArray : GLObject {
public:
    this() {
        glGenVertexArrays(1, &id);
    }

    ~this() {
        glDeleteVertexArrays(1, &id);
    }

    /// Binds the vertex array
    override void Bind() {
        Bind(0);
    }

    /// Binds the vertex array
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundVertexArray is this) return;

        // Bind to new position.
        boundVertexArray = this;
        glBindVertexArray(id);
    }

    /// Unbinds the vertex array (binds vertex array 0)
    override void Unbind() {
        /// If another vertex array is bound there, bail out.
        if (boundVertexArray !is this) return;

        /// Unbind target.
        glBindVertexArray(0);
        boundVertexArray = null;
    }

    void EnableArray(GLuint index) {
        glEnableVertexAttribArray(index);
    }

    void DisableArray(GLuint index) {
        glDisableVertexAttribArray(index);
    }

    void AttribPointer(GLuint attribute, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const(GLvoid)* offset) {
        glVertexAttribPointer(attribute, size, type, normalized, stride, offset);
    }

    void AttribIPointer(GLuint attribute, GLint size, GLenum type, GLsizei stride, const(GLvoid)* offset) {
        glVertexAttribIPointer(attribute, size, type, stride, offset);
    }
}

// TODO: Implement features from this.

class Sampler : GLObject {
private:
    GLuint id;
    GLenum boundTarget;

public:
    this() {
        glGenSamplers(1, &id);
    }

    /// Binds the sampler
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundSamplers[target].id == id) return;

        // Unbind from old position if needed.
        if (boundTarget != 0) Unbind();

        // Bind to new position.
        boundTarget = target;
        boundSamplers[boundTarget] = this;
        glBindSampler(target, id);
    }

    /// Unbinds the sampler (binds sampler 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundTarget == 0) return;

        /// If another sampler is bound there, bail out.
        if (boundSamplers[boundTarget].id != id) return;

        /// Unbind target.
        glBindSampler(boundTarget, 0);
        boundSamplers[boundTarget] = null;
        boundTarget = 0;
    }
}

// TODO: Implement these
/*
class AsyncQuery : GLObject {
private:
    GLuint id;
    GLenum boundTarget;

public:
    this() {
        glGenQueries(1, &id);
    }
}

class Pipeline : GLObject {
private:
    GLuint id;
    GLenum boundTarget;

public:
    this() {
        glGenProgramPipelines(1, &id);
    }
}

class TransformFeedback : GLObject {
private:
    GLuint id;
    GLenum boundTarget;

public:
    this() {
        glGenTransformFeedbacks(1, &id);
    }
}*/
