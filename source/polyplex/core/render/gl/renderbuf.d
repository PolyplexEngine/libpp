module polyplex.core.render.gl.renderbuf;
import core = polyplex.core.render;
import polyplex.core.render.gl.gloo;
import polyplex.core.render.gl.gloo : RBO = Renderbuffer, FBO = Framebuffer;
import core.memory : GC;

enum Attachment {
    Color0=GL_COLOR_ATTACHMENT0,
    Color1=GL_COLOR_ATTACHMENT1,
    Color2=GL_COLOR_ATTACHMENT2,
    Color3=GL_COLOR_ATTACHMENT3,
    Color4=GL_COLOR_ATTACHMENT4,
    Color5=GL_COLOR_ATTACHMENT5,
    Color6=GL_COLOR_ATTACHMENT6,
    Color7=GL_COLOR_ATTACHMENT7,
    Color8=GL_COLOR_ATTACHMENT8,
    Color9=GL_COLOR_ATTACHMENT9,
    Color10=GL_COLOR_ATTACHMENT10,
    Color11=GL_COLOR_ATTACHMENT11,
    Color12=GL_COLOR_ATTACHMENT12,
    Color13=GL_COLOR_ATTACHMENT13,
    Color14=GL_COLOR_ATTACHMENT14,
    Color15=GL_COLOR_ATTACHMENT15,
    Depth=GL_DEPTH_ATTACHMENT
}

public class Framebuffer {
private:
    int             width;
    int             height;
    FBO             fbo;
    RBO             rbo;
    Texture[]       renderTextures;
    GLenum[]        drawBufs;

    void bufferTexture() {
        fbo.Bind();

        // Prepare textures.
        foreach(to; renderTextures) {
            if (to is null) continue;
            to.Bind(TextureType.Tex2D);
            to.Image2D(TextureType.Tex2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
            to.SetParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
            to.SetParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
            to.Unbind();
        }

        rbo.Bind(); 
        rbo.Storage(GL_DEPTH_COMPONENT, width, height);
        fbo.Renderbuffer(FramebufferType.Multi, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo.Id);

        // Attach textures.
        foreach(i, to; renderTextures) {
            to.Bind(TextureType.Tex2D);
            fbo.Texture(GL_FRAMEBUFFER, drawBufs[i], to.Id, 0);
            to.Unbind();
        }
        GL.DrawBuffers(cast(int)drawBufs.length, drawBufs.ptr);
    }

    void updateTextureBuffer() {

    }

public:
    @property int Width() {
        return width;
    }

    @property int Height() {
        return height;
    }

    this(int width, int height, int colorAttachments = 1) {
        this.width = width;
        this.height = height;

        fbo = new FBO();
        rbo = new RBO();

        // Add color attachment textures
        foreach(i; 0..colorAttachments) {
            drawBufs ~= GL_COLOR_ATTACHMENT0+cast(uint)i;
            renderTextures ~= new Texture();
        }

        // Setup framebuffer
        bufferTexture();
        fbo.Unbind();
    }
    ~this() {
        destroy(fbo);
        destroy(renderTextures);
        destroy(rbo);
    }

    Texture[] OutTextures() {
        return renderTextures;
    }

    /**
        Resize destroys the current framebuffer and recreates it with the specified size.
    */
    void Resize(int width, int height) {
        immutable(size_t) colorAttachments = renderTextures.length;
        destroy(rbo);
        destroy(fbo);
        destroy(renderTextures);
        destroy(drawBufs);
        GC.collect();
        

        this.width = width;
        this.height = height;

        fbo = new FBO();
        rbo = new RBO();

        // TODO: Optimize this.
        renderTextures = new Texture[colorAttachments];
        foreach(i; 0..colorAttachments) {
            drawBufs ~= GL_COLOR_ATTACHMENT0+cast(uint)i;
            renderTextures[i] = new Texture();
        }

        // Setup framebuffer
        bufferTexture();
        fbo.Unbind();
    }

    void Begin() {
        fbo.Bind();
        GL.Viewport(0, 0, width, height);
    }

    void End() {
        GL.BindFramebuffer(GL_FRAMEBUFFER, 0);
        fbo.Unbind();
    }
}