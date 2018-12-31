module polyplex.core.render.gl.renderbuf;
import core = polyplex.core.render;
import polyplex.core.render.gl.gloo;


public class GlFramebufferImpl : core.FramebufferImpl {
private:
    Framebuffer     fbo;
    Renderbuffer    rbo;
    Texture         to;
    GLenum[] drawBufs;

    void bufferTexture() {
        fbo.Bind();
        to.Bind(TextureType.Tex2D);

        to.Image2D(TextureType.Tex2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
        to.SetParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
        to.SetParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);

        rbo.Bind();
        rbo.Storage(GL_DEPTH_COMPONENT, width, height);
        fbo.Renderbuffer(FramebufferType.Multi, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo.Id);
        fbo.Texture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, to.Id, 0);
        GL.DrawBuffers(1, drawBufs.ptr);
    }

    void updateTextureBuffer() {

    }

public:
    override @property int Width() {
        return width;
    }

    override @property int Height() {
        return height;
    }

    this(int width, int height) {
        super(width, height);
        fbo = new Framebuffer();
        to  = new Texture();
        rbo = new Renderbuffer();

        drawBufs = [GL_COLOR_ATTACHMENT0];

        // Setup framebuffer
        bufferTexture();
    }
    ~this() {
        destroy(fbo);
        destroy(to);
        destroy(rbo);
    }

    Texture OutTexture() {
        return this.to;
    }

    override void Resize(int width, int height) {
        destroy(rbo);
        destroy(fbo);
        destroy(to);

        this.width = width;
        this.height = height;

        fbo = new Framebuffer();
        to  = new Texture();
        rbo = new Renderbuffer();

        // Setup framebuffer
        bufferTexture();
    }

    override void Begin() {
        //destroy(rbo);
        //destroy(to);
        //to  = new Texture();
        //rbo = new Renderbuffer();
        fbo.Bind(FramebufferType.Multi);
        to.Bind();
        bufferTexture();
        GL.Viewport(0, 0, width, height);
    }

    static void End() {
        GL.BindFramebuffer(GL_FRAMEBUFFER, 0);
    }
}