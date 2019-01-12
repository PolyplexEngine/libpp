module polyplex.core.render.gl.renderbuf;
import core = polyplex.core.render;
import polyplex.core.render.gl.gloo;

enum Attachment {
    Color=GL_COLOR_ATTACHMENT0,
    Depth=GL_DEPTH_ATTACHMENT
}

public class GlFramebufferImpl : core.FramebufferImpl {
private:
    Framebuffer     fbo;
    Renderbuffer    rbo;
    Texture[]       renderTextures;
    GLenum[] drawBufs;

    void bufferTexture() {
        fbo.Bind();

        // Prepare textures.
        foreach(to; renderTextures) {
            if (to is null) continue;
            to.Bind(TextureType.Tex2D);
            to.Image2D(TextureType.Tex2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
            to.SetParameter(TextureType.Tex2D, TextureParameter.MagFilter, GL.Nearest);
            to.SetParameter(TextureType.Tex2D, TextureParameter.MinFilter, GL.Nearest);
        }

        rbo.Bind(); 
        rbo.Storage(GL_DEPTH_COMPONENT, width, height);
        fbo.Renderbuffer(FramebufferType.Multi, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo.Id);

        // Attach textures.
        foreach(i, to; renderTextures) {
            to.Bind(TextureType.Tex2D);
            fbo.Texture(GL_FRAMEBUFFER, drawBufs[i], to.Id, 0);
        }
        GL.DrawBuffers(cast(int)drawBufs.length, drawBufs.ptr);
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

    this(int width, int height, int colorAttachments = 1) {
        super(width, height, colorAttachments);
        fbo = new Framebuffer();
        rbo = new Renderbuffer();

        int colors = 0;
        foreach(i; 0..colorAttachments) {
            drawBufs ~= GL_COLOR_ATTACHMENT0+colors;
            renderTextures ~= new Texture();
            colors++;
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

    override void Resize(int width, int height, int colorAttachments = 1) {
        destroy(rbo);
        destroy(fbo);
        destroy(renderTextures);
        destroy(drawBufs);

        this.width = width;
        this.height = height;

        fbo = new Framebuffer();
        rbo = new Renderbuffer();

        // TODO: Optimize this.
        renderTextures = new Texture[colorAttachments];
        if (colorAttachments != drawBufs.length) {
            drawBufs = [];
            int colors;
            foreach(i; 0..colorAttachments) {
                drawBufs ~= GL_COLOR_ATTACHMENT0+colors;
                renderTextures[i] = new Texture();
                colors++;
            }
        }

        // Setup framebuffer
        bufferTexture();
        fbo.Unbind();
    }

    override void Begin() {
        //destroy(rbo);
        //destroy(to);
        //to  = new Texture();
        //rbo = new Renderbuffer();
        fbo.Bind(FramebufferType.Multi);
        bufferTexture();
        GL.Viewport(0, 0, width, height);
    }

    static void End() {
        GL.BindFramebuffer(GL_FRAMEBUFFER, 0);
    }
}