module polyplex.core.render.gl.gloo;
public import bindbc.opengl;

private __gshared Buffer[GLenum]            boundBuffers;
private __gshared Texture[GLenum]           boundTextures;
private __gshared Framebuffer[GLenum]       boundFramebuffers;
private __gshared Sampler[GLenum]           boundSamplers;
private __gshared Renderbuffer[GLenum]      boundRenderbuffers;
private __gshared VertexArray               boundVertexArray;
//private __gshared AsyncQuery[GLenum]        boundAsyncQueries;
//private __gshared Pipeline[GLenum]          boundPipelines;
//private __gshared TransformFeedback[GLenum] boundTransformFeedbacks;

enum ObjectClass {
    Anything,
    Data,
    Texture
}
public:

abstract class GLObject {
private:
    GLuint id;
public:
    abstract void Bind(GLenum target);
    abstract void Unbind();
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

    /// Binds the buffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundBuffers[target].id == id) return;

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
    void Data(GLenum target, ptrdiff_t size, void* data, GLenum usage) {
        Bind(target);
        glBufferData(target, size, data, usage);
    }

    /// 
    void SubData(GLenum target, ptrdiff_t offset, ptrdiff_t size, void* data) {
        Bind(target);
        glBufferSubData(target, offset, size, data);
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

    /// Binds the texture
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundTextures[target].id == id) return;

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
        glTexParameteri(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLfloat param) {
        Bind(target);
        glTexParameterf(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLint* param) {
        Bind(target);
        glTexParameteriv(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, GLfloat* param) {
        Bind(target);
        glTexParameterfv(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, const(GLint)* param) {
        Bind(target);
        glTexParameterIiv(target, pname, param);
    }

    /// 
    void SetParameter(GLenum target, GLenum pname, const(GLuint)* param) {
        Bind(target);
        glTexParameterIuiv(target, pname, param);
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

    /// Binds the framebuffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundFramebuffers[target].id == id) return;

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

class Renderbuffer : GLObject {
private:
    GLenum boundTarget;

public:
    this() {
        glGenRenderbuffers(1, &id);
    }

    ~this() {
        glDeleteRenderbuffers(1, &id);
    }

    /// Binds the renderbuffer
    override void Bind(GLenum target) {
        // We're already bound there, bail out.
        if (boundRenderbuffers[target].id == id) return;

        // Unbind from old position if needed.
        if (boundTarget != 0) Unbind();

        // Bind to new position.
        boundTarget = target;
        boundRenderbuffers[boundTarget] = this;
        glBindRenderbuffer(target, id);
    }

    /// Unbinds the renderbuffer (binds renderbuffer 0)
    override void Unbind() {
        /// Skip unbinding if not bound in the first place.
        if (boundTarget == 0) return;

        /// If another renderbuffer is bound there, bail out.
        if (boundRenderbuffers[boundTarget].id != id) return;

        /// Unbind target.
        glBindRenderbuffer(boundTarget, 0);
        boundRenderbuffers[boundTarget] = null;
        boundTarget = 0;
    }

    /// 
    void Storage(GLenum target, GLenum internalFormat, GLsizei width, GLsizei height) {
        glRenderbufferStorage(target, internalFormat, width, height);
    }

    /// 
    void StorageMultisample(GLenum target, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height) {
        glRenderbufferStorageMultisample(target, samples, internalFormat, width, height);
    }
}

class VertexArray : GLObject {
public:
    this() {
        glGenVertexArrays(1, &id);
    }

    ~this() {
        glDeleteVertexArrays(1, &id);
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

    void AttribLPointer(GLuint attribute, GLint size, GLenum type, GLsizei stride, const(GLvoid)* offset) {
        glVertexAttribLPointer(attribute, size, type, stride, offset);
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
