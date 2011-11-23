#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"

// #define OPENGL_ANALYZER_RECOMMENDS

@interface EAGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation EAGLView

@dynamic context;
@synthesize frameBuffer;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame {
	if( self = [super initWithFrame:frame] ) {
		[self setMultipleTouchEnabled:YES];
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
    return self;
}


- (void)dealloc {
    [self deleteFramebuffer];    
    [context release];
    [super dealloc];
}


- (EAGLContext *)context {
    return context;
}


- (void)setContext:(EAGLContext *)newContext {
    if (context != newContext) {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)createFramebuffer {
    if (context && !frameBuffer) {
		[EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
 //       NSLog(@"---EAGLView: createFramebuffer: %d, width: %d, height: %d", frameBuffer, framebufferWidth, framebufferHeight);
		
		
/***********
 start AA code
*************/
//		//frame buffer
//		glGenFramebuffers(1, &msaaFramebuffer); 
//		glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer); 
//		
//		//render buffer
//		glGenRenderbuffers(1, &msaaRenderBuffer);   
//		glBindRenderbuffer(GL_RENDERBUFFER, msaaRenderBuffer);   
//		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA, framebufferWidth, framebufferHeight); 
//		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, msaaRenderBuffer); 
//
//		//depth buffer
//		glGenRenderbuffers(1, &msaaDepthBuffer);   
//		glBindRenderbuffer(GL_RENDERBUFFER, msaaDepthBuffer); 
//		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight); 
//		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, msaaDepthBuffer);
/***********
 end AA code
*************/		
		
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}


- (void)deleteFramebuffer {
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (frameBuffer)
        {
//            NSLog(@"--- deleteFramebuffer: %d ----", frameBuffer);
            glDeleteFramebuffers(1, &frameBuffer);
            frameBuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer {
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!frameBuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);  // Check if this is redundant
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}


- (BOOL)presentFramebuffer {
    BOOL success = FALSE;
    
    if (context) {
        [EAGLContext setCurrentContext:context];

		
//AA code
//		//Bind both MSAA and View FrameBuffers. 
//		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, frameBuffer);   
//		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer); 
//		
//		// Call a resolve to combine both buffers 
//		glResolveMultisampleFramebufferAPPLE();  
//		
//		//Discard render buffers
//		const GLenum discards[]  = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
//		glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);   
//
//		// Present final image to screen 
//		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);		
//end AA code
		success = [context presentRenderbuffer:GL_RENDERBUFFER];
		
//AA code		
//		//discard
//		glDiscardFramebufferEXT(GL_DRAW_FRAMEBUFFER_APPLE, 1, GL_COLOR_ATTACHMENT0);		
//		
//		//clear the frameBuffer
//		glBindFramebuffer(GL_FRAMEBUFFER, msaaFramebuffer);	
//		glViewport(0, 0, framebufferWidth, framebufferHeight);
//        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//end AA code
		
		//clear the frameBuffer
        glClear(GL_COLOR_BUFFER_BIT);
		
    }
    
    return success;
}


- (void)layoutSubviews {
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

@end
