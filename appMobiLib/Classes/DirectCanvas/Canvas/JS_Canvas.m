#import "JS_Canvas.h"
#import "JS_Texture.h"

gl_color JSValueToColor(JSContextRef ctx, JSValueRef value) {
	gl_color c = {.hex = 0xffffffff};
	
	if( !JSValueIsString(ctx, value) ) {
		return c;
	}
	
	JSStringRef jsString = JSValueToStringCopy( ctx, value, NULL );
	int length = JSStringGetLength( jsString );
	
	const JSChar * jsc = JSStringGetCharactersPtr(jsString);
	char str[] = "ffffff";
	
	// #f0f format
	if( length == 4 ) {
		str[0] = str[1] = jsc[3];
		str[2] = str[3] = jsc[2];
		str[4] = str[5] = jsc[1];
		c.hex = 0xff000000 | strtol( str, NULL, 16 );
	}
	
	// #ff00ff format
	else if( length == 7 ) {
		str[0] = jsc[5];
		str[1] = jsc[6];
		str[2] = jsc[3];
		str[3] = jsc[4];
		str[4] = jsc[1];
		str[5] = jsc[2];
		c.hex = 0xff000000 | strtol( str, NULL, 16 );
	}
	
	// rgb(255,0,255) format
	else { 
		GLubyte components[3] = {0,0,0};
		int current = 0;
		for( int i = 0; i < length && current < 3; i++ ) {
			if( isdigit(jsc[i]) ) {
				components[current] = components[current] * 10 + jsc[i] - '0'; 
			}
			else if( jsc[i] == ',' || jsc[i] == ')' ) {
				current++;
			}
		}
		c.rgba.r = components[0];
		c.rgba.g = components[1];
		c.rgba.b = components[2];
	}
	JSStringRelease(jsString);
	return c;
}


@implementation JS_Canvas

GLuint CanvasGlobalTextureFrameBuffer = 0;
EAGLContext * CanvasGlobalGLContext = nil;
JS_Canvas * CanvasCurrentInstance = NULL;
int prevWidth=0, prevHeight=0;
float prevScale=0;
BOOL prevInverted=false;

@synthesize texture;


// -------------------------------------------------------------------------------------
// init

- (void) setglDimentionsWithWidth:(int)_width Height:(int)_height Scale:(float)_scale {
    if(prevWidth != _width || prevHeight != _height || prevScale != _scale || prevInverted != inverted) {
//        NSLog(@"-------> setting gl dimentions. Width = %d, height = %d", _width, _height);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrthof(0, _width*_scale, _height*_scale, 0, -1, 1);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        if(!inverted) {
            glTranslatef(0, _height, 0);
            glScalef(_scale, -_scale, 1);
        } else {
            glScalef(_scale, _scale, 1);
        }
        
        prevWidth = _width;
        prevHeight = _height;
        prevScale = _scale;
        prevInverted = inverted;
    }
   else {
//        NSLog(@"-------> gl dimentions not set: Width = %d, height = %d", _width, _height);
    }
}

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
    	self  = [super initWithContext:ctx object:obj argc:argc argv:argv];
	if( self ) {
		scale = 1; // initial values, will be modified by setting the actual size
		width = 128;
		height = 128;
		inverted = FALSE;
		
		globalAlpha = 255;
		fillColor.hex = 0xffffffff;
		strokeColor.hex = 0xffffffff;
		clearColor[0] = 0;
		clearColor[1] = 0;
		clearColor[2] = 0;
		clearColor[3] = 1;

		// drawing mode
		rectDrawMode = lastRectDrawMode=DRAWMODE_FILL; // init to fillRect
		pathIsModified = FALSE; // set at path fill or stroke
		
		// Create the global GLContext if we don't have one already
		if( !CanvasGlobalGLContext ) {
			CanvasGlobalGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
			if (!CanvasGlobalGLContext) {
				NSLog(@"GLDraw: Failed to create ES context");
			}
			else if (![EAGLContext setCurrentContext:CanvasGlobalGLContext]) {
				NSLog(@"GLDraw: Failed to set ES context current");
			}
		}		

        	[self setglDimentionsWithWidth:width Height:height Scale:scale];
	}
	return self;
}


- (void)dealloc {
    if(CanvasCurrentInstance==self) CanvasCurrentInstance = NULL;
	if( texture ) [texture release];
	if( canvasPath ) [canvasPath release];
	[super dealloc];
}


- (void)switchToThisCanvas {
	[CanvasCurrentInstance flushBuffers:TRUE];
	
	[self setglDimentionsWithWidth:width Height:height Scale:scale];
    
	[self prepareThisCanvas];
	currentTexture = nil;
	CanvasCurrentInstance = self;
	
	quadIndex = 0;
	drawCalls = 0;
	
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, quadVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, vertexColors);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
}


// -------------------------------------------------------------------------------------
// Setup

GLuint colorRenderbuffer;

- (void)createFramebuffer {
    if (CanvasGlobalGLContext && !CanvasGlobalTextureFrameBuffer) {
   
        // Create default framebuffer object.
        glGenFramebuffersOES(1, &CanvasGlobalTextureFrameBuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER, CanvasGlobalTextureFrameBuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER, colorRenderbuffer);
        
        glRenderbufferStorageOES(GL_RENDERBUFFER, GL_RGBA8_OES, width, height);
     
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.textureId, 0);

        int framebufferWidth, framebufferHeight; // just to get val for log
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
//        NSLog(@"---JS_Canvas createFramebuffer: %d, width: %d, height: %d", CanvasGlobalTextureFrameBuffer, framebufferWidth, framebufferHeight);
        
        if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"JS_Canvas: Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));

    }
}

- (void) deleteFrameBuffer {
    if (CanvasGlobalGLContext) {
        [EAGLContext setCurrentContext:CanvasGlobalGLContext];
        
        if (CanvasGlobalTextureFrameBuffer)
        {
//            NSLog(@"--- deleteFramebuffer: %d ----", CanvasGlobalTextureFrameBuffer);
            glDeleteFramebuffers(1, &CanvasGlobalTextureFrameBuffer);
            CanvasGlobalTextureFrameBuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
    
}

- (void)setFrameBuffer {
	[EAGLContext setCurrentContext:CanvasGlobalGLContext];
	
	// Create a global texture framebuffer
	if( !CanvasGlobalTextureFrameBuffer ) {
        [self createFramebuffer];
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, CanvasGlobalTextureFrameBuffer);
	glViewport(0, 0, width, height);
	// NSLog(@"viewport: %d, %d", width, height);
}

// We removed this from prepareThisCanvas to lazily initialize to reduce memory
- (void)initializeCanvasPath {
    // path api 
    if( !canvasPath ) {
        canvasPath = [[CanvasPath alloc] initWithWidth:width height:height];
    }
}

- (void)prepareThisCanvas {
	if( !texture ) {
		[CanvasCurrentInstance flushBuffers:TRUE];
		texture = [[Texture alloc] initWithWidth:width height:height];
	}
 	[self deleteFrameBuffer];
	[self setFrameBuffer];

	// path api 
	if( !canvasPath ) {
		//canvasPath = [[CanvasPath alloc] initWithWidth:width height:height];
	}

 	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.textureId, 0); //:keep?
 /*	
	GLint framebufferWidth, framebufferHeight; // just to get val for log
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
	NSLog(@"--- prepareThisCanvas: %d, width: %d, height: %d", CanvasGlobalTextureFrameBuffer, framebufferWidth, framebufferHeight);
*/
   
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}



// -------------------------------------------------------------------------------------
// Drawing

- (void)flushBuffers:(BOOL) drawPath {

#ifdef USE_DRAW_ELEMENTS
    static GLubyte indices[] = {
	0,1,2,1,2,3, 
	4,5,6,5,6,7, 
	8,9,10,9,10,11, 
	12,13,14,13,14,15, 
	16,17,18,17,18,19, 
	20,21,22,21,22,23, 
	24,25,26,25,26,27, 
	28,29,30,29,30,31, 
	32,33,34,33,34,35, 
	36,37,38,37,38,39, 
	40,41,42,41,42,43, 
	44,45,46,45,46,47, 
	48,49,50,49,50,51, 
	52,53,54,53,54,55, 
	56,57,58,57,58,59, 
	60,61,62,61,62,63, 
	64,65,66,65,66,67, 
	68,69,70,69,70,71, 
	72,73,74,73,74,75, 
	76,77,78,77,78,79, 
	80,81,82,81,82,83, 
	84,85,86,85,86,87, 
	88,89,90,89,90,91, 
	92,93,94,93,94,95, 
	96,97,98,97,98,99, 
	100,101,102,101,102,103, 
	104,105,106,105,106,107, 
	108,109,110,109,110,111, 
	112,113,114,113,114,115, 
	116,117,118,117,118,119, 
	120,121,122,121,122,123, 
	124,125,126,125,126,127, 
	128,129,130,129,130,131, 
	132,133,134,133,134,135, 
	136,137,138,137,138,139, 
	140,141,142,141,142,143, 
	144,145,146,145,146,147, 
	148,149,150,149,150,151, 
	152,153,154,153,154,155, 
	156,157,158,157,158,159, 
	160,161,162,161,162,163, 
	164,165,166,165,166,167, 
	168,169,170,169,170,171, 
	172,173,174,173,174,175, 
	176,177,178,177,178,179, 
	180,181,182,181,182,183, 
	184,185,186,185,186,187, 
	188,189,190,189,190,191, 
	192,193,194,193,194,195, 
	196,197,198,197,198,199, 
	200,201,202,201,202,203, 
	204,205,206,205,206,207, 
	208,209,210,209,210,211, 
	212,213,214,213,214,215, 
	216,217,218,217,218,219, 
	220,221,222,221,222,223, 
	224,225,226,225,226,227, 
	228,229,230,229,230,231, 
	232,233,234,233,234,235, 
	236,237,238,237,238,239, 
	240,241,242,241,242,243, 
	244,245,246,245,246,247, 
	248,249,250,249,250,251, 
	252,253,254,253,254,255
    };
#endif
	
	[self setglDimentionsWithWidth:width Height:height Scale:scale];
	if(pathIsModified && (drawPath || (quadIndex != 0))) {
		pathIsModified = FALSE;
		[self drawPath];
	}
	
	if( quadIndex != 0 ) {
	// NSLog(@"flush %d quads!", quadIndex);
		if(lastRectDrawMode==DRAWMODE_FILL)   
#ifdef USE_DRAW_ELEMENTS
            glDrawElements(GL_TRIANGLES, 6 * quadIndex, GL_UNSIGNED_BYTE, indices);
#else
            glDrawArrays(GL_TRIANGLES, 0, 6 * quadIndex);
#endif
		else {
			// strokeRect
			for(int i=0; i<quadIndex ; i++)
				glDrawArrays(GL_LINE_STRIP, i*6, 5);
		}
		drawCalls++;
	}
	
	lastRectDrawMode = rectDrawMode;
	
	quadIndex = 0;
}


- (void)setCurrentTextureFromDrawable:(NSObject<Drawable> *)drawable {
	if( CanvasCurrentInstance != self ) {
		[self switchToThisCanvas];
	}
	
	if( !drawable && currentTexture ) {
		[self flushBuffers:TRUE];
		glDisable(GL_TEXTURE_2D);
		currentTexture = nil;
	}
	
	Texture * newTexture = drawable.texture;
	if( newTexture != currentTexture ) {
		[self flushBuffers:TRUE];
        if(!glIsEnabled(GL_TEXTURE_2D)) {
            glEnable(GL_TEXTURE_2D);
        }
		currentTexture = newTexture;
        [currentTexture bind];
	}
}


- (void)drawQuadWithColor:(GLuint)color
	sx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh
	dx:(float)dx dy:(float)dy dw:(float)dw dh:(float)dh
	flipX:(BOOL)flipX flipY:(float)flipY
{	
	// first draw?
	if( drawCalls == 0 && quadIndex == 0 ) {
		[self setFrameBuffer];
	}
	else if( quadIndex >= CANVAS_CONTEXT_BUFFER_SIZE ) {
		[self flushBuffers:TRUE];
	}
		
	if(rectDrawMode != lastRectDrawMode)
		[self flushBuffers:FALSE];
	
	GLfloat * qv = quadVertices[quadIndex];
	GLfloat * tv = textureVertices[quadIndex];
	GLuint * cv = (GLuint *)vertexColors[quadIndex];
	
	if( scale != 1 ) {
		dx = round(dx*scale)/scale;
		dy = round(dy*scale)/scale;
	}
	
	cv[0] = cv[1] = cv[2] = cv[3] = cv[4] = cv[5] = color;
                 
	if(rectDrawMode==DRAWMODE_FILL) {  // fillRect
	
#ifdef USE_DRAW_ELEMENTS
        qv[4] = qv[0] = dx;
		qv[3] = qv[1] = dy;
		qv[6] = qv[2] = dx + dw;
		qv[7] = qv[5] = dy + dh;
#else
		qv[8] = qv[4] = qv[0] = dx;
		qv[7] = qv[3] = qv[1] = dy;
		qv[10] = qv[6] = qv[2] = dx + dw;
		qv[11] = qv[9] = qv[5] = dy + dh;
#endif
		// do we have a texture?
		if( currentTexture ) {
			float tw = currentTexture.realWidth;
			float th = currentTexture.realHeight;

#ifdef USE_DRAW_ELEMENTS
            tv[4] = tv[0] = flipX ? (sx + sw) / tw : sx / tw;
			tv[3] = tv[1] = flipY ? (sy + sh) / th : sy / th;
			tv[6] = tv[2] = flipX ? sx / tw : (sx + sw) / tw;
			tv[7] = tv[5] = flipY ? sy / th : (sy + sh) / th;
#else
			tv[8] = tv[4] = tv[0] = flipX ? (sx + sw) / tw : sx / tw;
			tv[7] = tv[3] = tv[1] = flipY ? (sy + sh) / th : sy / th;
			tv[10] = tv[6] = tv[2] = flipX ? sx / tw : (sx + sw) / tw;
			tv[11] = tv[9] = tv[5] = flipY ? sy / th : (sy + sh) / th;
#endif
        }
		
		
	}
	else { //strokeRect
		qv[0] = qv[6] = qv[8] = dx;
		qv[1] = qv[3] = qv[9] = dy;
		qv[2] = qv[4] = dx + dw;
		qv[5] = qv[7] = dy + dh;
	}

	quadIndex++;
}

- (void) drawPath {
	
	glPushMatrix();
	glLoadIdentity();  //: check if we need to scale
	
	currentTexture = 0; // ensure the CG texture will be drawn and bounded
	[self setCurrentTextureFromDrawable:(NSObject<Drawable> *) canvasPath];
	[currentTexture texImage:canvasPath.pixels];
	
	float
	dx = 0,
	dy = 0,
	w = currentTexture.width,
	h = currentTexture.height;
	
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	rectDrawMode=DRAWMODE_FILL;
	[self drawQuadWithColor:color.hex
						 sx:0 sy:0 sw:w sh:h
						 dx:dx dy:dy dw:w dh:h
					  flipX:NO flipY:YES];
	
	[self flushBuffers:FALSE];  // this is to ensure the path is drawn before poping the matrix
	[canvasPath clear];
	glPopMatrix();

	return;
}

JS_FUNC(JS_Canvas, drawImageTile, ctx, argc, argv) {
	if( argc < 3 || !JSValueIsObject(ctx, argv[0]) ) return NULL;

    JSObjectRef image = JSValueToObject(ctx,(JSObjectRef)argv[0] ,NULL);
    JSObjectRef imageData = (JSObjectRef)JSObjectGetProperty(ctx, image, JSStringCreateWithUTF8CString("data"), NULL);
    NSObject<Drawable> * imageDataInternal = (NSObject<Drawable> *)JSObjectGetPrivate(imageData);
    
	[self setCurrentTextureFromDrawable:imageDataInternal];
	
	float sx, sy, sw, sh, dx, dy, dw, dh;
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	BOOL flipX = NO, flipY = NO;
	
	if( argc > 7 ) {
		dx = JSValueToNumber(ctx, argv[1], NULL);
		dy = JSValueToNumber(ctx, argv[2], NULL);
		int t = JSValueToNumber(ctx, argv[3], NULL);
		
		dw = sw = JSValueToNumber(ctx, argv[4], NULL);
		dh = sh = JSValueToNumber(ctx, argv[5], NULL);
		
		sx = (int)(t * sw) % (int)currentTexture.width;
		sy = (int)(t * sw / currentTexture.width) * sh;
		
		flipX = JSValueToBoolean(ctx, argv[6]);
		flipY = JSValueToBoolean(ctx, argv[7]);
		if( argc > 8 ) {
			color.rgba.a = MIN(255,MAX(255 * JSValueToNumber(ctx, argv[8], NULL),0));
		}
	}
	else {
		dx = JSValueToNumber(ctx, argv[1], NULL);
		dy = JSValueToNumber(ctx, argv[2], NULL);
		color.rgba.a = MIN(255,MAX(255 * JSValueToNumber(ctx, argv[3], NULL),0));
		sx = sy = 0;
		sw = dw = currentTexture.width;
		sh = dh = currentTexture.height;
	}
	
	[self drawQuadWithColor:color.hex
		sx:sx sy:sy sw:sw sh:sh
		dx:dx dy:dy dw:dw dh:dh
		flipX:flipX flipY:flipY];
	
	return NULL;
}

JS_FUNC(JS_Canvas, drawRotatedImage, ctx, argc, argv) {
	if( (argc != 12) || !JSValueIsObject(ctx, argv[0]) ) return NULL;

	//save
    [self flushBuffers:FALSE];
    glPushMatrix();
    //[canvasPath save];
    
    //translate
    //[self flushBuffers:FALSE];
    GLfloat x = JSValueToNumber(ctx, argv[9], NULL), y= JSValueToNumber(ctx, argv[10], NULL);
    glTranslatef(x, y, 0);
    //[canvasPath translate:x ty:y];
    
    //rotate
    //[self flushBuffers:FALSE];
    GLfloat angle=JSValueToNumber(ctx, argv[11], NULL);
    glRotatef(angle*180.0/M_PI, 0, 0, 1);
    //[canvasPath rotate:angle];
    
    JSObjectRef image = JSValueToObject(ctx,(JSObjectRef)argv[0] ,NULL);
    JSObjectRef imageData = (JSObjectRef)JSObjectGetProperty(ctx, image, JSStringCreateWithUTF8CString("data"), NULL);
    NSObject<Drawable> * imageDataInternal = (NSObject<Drawable> *)JSObjectGetPrivate(imageData);
    
	if(imageDataInternal!=NULL) { //it's a fake Image
        [self setCurrentTextureFromDrawable:imageDataInternal];
    } else { //it's a Canvas
        [self setCurrentTextureFromDrawable:(NSObject<Drawable> *)JSObjectGetPrivate((JSObjectRef)argv[0])];
    }
	
    float dx, dy, dw, dh, sx, sy, sw, sh;
    sx = JSValueToNumber(ctx, argv[1], NULL);
    sy = JSValueToNumber(ctx, argv[2], NULL);
    sw = JSValueToNumber(ctx, argv[3], NULL);
    sh = JSValueToNumber(ctx, argv[4], NULL);
    dx = JSValueToNumber(ctx, argv[5], NULL);
    dy = JSValueToNumber(ctx, argv[6], NULL);
    dw = JSValueToNumber(ctx, argv[7], NULL);
    dh = JSValueToNumber(ctx, argv[8], NULL);
	
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	[self drawQuadWithColor:color.hex
                         sx:sx sy:sy sw:sw sh:sh
                         dx:dx dy:dy dw:dw dh:dh
                      flipX:NO flipY:NO];
    
    //restore
    [self flushBuffers:FALSE];
    glPopMatrix();
    //[canvasPath restore];

	return NULL;
}

JS_FUNC(JS_Canvas, drawImageTile2, ctx, argc, argv) {
	if( argc != 7 || !JSValueIsObject(ctx, argv[0]) ) return NULL;
    
    JSObjectRef image = JSValueToObject(ctx,(JSObjectRef)argv[0] ,NULL);
    JSObjectRef imageData = (JSObjectRef)JSObjectGetProperty(ctx, image, JSStringCreateWithUTF8CString("data"), NULL);
    NSObject<Drawable> * imageDataInternal = (NSObject<Drawable> *)JSObjectGetPrivate(imageData);
    
	[self setCurrentTextureFromDrawable:imageDataInternal];
	
	float sx, sy, sw, sh, dx, dy, dw, dh;
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	BOOL flipX = NO, flipY = NO;
	
    dx = JSValueToNumber(ctx, argv[1], NULL);
    dy = JSValueToNumber(ctx, argv[2], NULL);
    int t = JSValueToNumber(ctx, argv[3], NULL);
    
    JS_Texture * jstext = (JS_Texture *) imageDataInternal;
    dw = sw = jstext.framewidth;
    dh = sh = jstext.frameheight;
    
    sx = (int)(t * sw) % (int)currentTexture.width;
    sy = (int)(t * sw / currentTexture.width) * sh;
    
    flipX = JSValueToBoolean(ctx, argv[4]);
    flipY = JSValueToBoolean(ctx, argv[5]);
    if( argc > 8 ) {
        color.rgba.a = MIN(255,MAX(255 * JSValueToNumber(ctx, argv[6], NULL),0));
    }
	
	[self drawQuadWithColor:color.hex
                         sx:sx sy:sy sw:sw sh:sh
                         dx:dx dy:dy dw:dw dh:dh
                      flipX:flipX flipY:flipY];
	
	return NULL;
}

JS_FUNC(JS_Canvas, drawRotatedImage2, ctx, argc, argv) {
	if( (argc != 7) || !JSValueIsObject(ctx, argv[0]) ) return NULL;

	//save
    [self flushBuffers:FALSE];
    glPushMatrix();
    //[canvasPath save];
    
    //translate
    //[self flushBuffers:FALSE];
    GLfloat x = JSValueToNumber(ctx, argv[4], NULL), y= JSValueToNumber(ctx, argv[5], NULL);
    glTranslatef(x, y, 0);
    //[canvasPath translate:x ty:y];
    
    //rotate
    //[self flushBuffers:FALSE];
    GLfloat angle=JSValueToNumber(ctx, argv[6], NULL);
    glRotatef(angle*180.0/M_PI, 0, 0, 1);
    //[canvasPath rotate:angle];
    
    JSObjectRef image = JSValueToObject(ctx,(JSObjectRef)argv[0] ,NULL);
    JSObjectRef imageData = (JSObjectRef)JSObjectGetProperty(ctx, image, JSStringCreateWithUTF8CString("data"), NULL);
    NSObject<Drawable> * imageDataInternal = (NSObject<Drawable> *)JSObjectGetPrivate(imageData);
    
	if(imageDataInternal!=NULL) { //it's a fake Image
        [self setCurrentTextureFromDrawable:imageDataInternal];
    } else { //it's a Canvas
        [self setCurrentTextureFromDrawable:(NSObject<Drawable> *)JSObjectGetPrivate((JSObjectRef)argv[0])];
    }
	
    float dx, dy, dw, dh, sx, sy, sw, sh;
    dx = JSValueToNumber(ctx, argv[2], NULL);
    dy = JSValueToNumber(ctx, argv[3], NULL);
    int t = JSValueToNumber(ctx, argv[1], NULL);
    
    JS_Texture * jstext = (JS_Texture *) imageDataInternal;
    dw = sw = jstext.framewidth;
    dh = sh = jstext.frameheight;

    sx = (int)(t * sw) % (int)currentTexture.width;
    sy = (int)(t * sw / currentTexture.width) * sh;
	
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	[self drawQuadWithColor:color.hex
                         sx:sx sy:sy sw:sw sh:sh
                         dx:dx dy:dy dw:dw dh:dh
                      flipX:NO flipY:NO];
    
    //restore
    [self flushBuffers:FALSE];
    glPopMatrix();
    //[canvasPath restore];
    
	return NULL;
}

JS_FUNC(JS_Canvas, drawImage, ctx, argc, argv) {
	if( (argc != 3 && argc != 5 && argc != 9) || !JSValueIsObject(ctx, argv[0]) ) return NULL;
	
    JSObjectRef image = JSValueToObject(ctx,(JSObjectRef)argv[0] ,NULL);
    bool isAFakeImage = JSObjectHasProperty(ctx, image, JSStringCreateWithUTF8CString("data"));
    NSObject<Drawable> * imageDataInternal = NULL;
    if(isAFakeImage) {
        JSObjectRef imageData = (JSObjectRef)JSObjectGetProperty(ctx, image, JSStringCreateWithUTF8CString("data"), NULL);
        imageDataInternal = (NSObject<Drawable> *)JSObjectGetPrivate(imageData);
    }
    
	if(isAFakeImage) { //it's a fake Image
        [self setCurrentTextureFromDrawable:imageDataInternal];
    } else { //it's a Canvas
        [self setCurrentTextureFromDrawable:(NSObject<Drawable> *)JSObjectGetPrivate((JSObjectRef)argv[0])];
    }
	
    float dx, dy, dw, dh, sx, sy, sw, sh;
    
    if(argc==3) {
        sx = 0;
        sy = 0;
		sw = currentTexture.width;
		sh = currentTexture.height;
		dx = JSValueToNumber(ctx, argv[1], NULL);
		dy = JSValueToNumber(ctx, argv[2], NULL);
		dw = currentTexture.width;
		dh = currentTexture.height;
    } else if(argc==5) {
        sx = 0;
        sy = 0;
		sw = currentTexture.width;
		sh = currentTexture.height;
		dx = JSValueToNumber(ctx, argv[1], NULL);
		dy = JSValueToNumber(ctx, argv[2], NULL);
		dw = JSValueToNumber(ctx, argv[3], NULL);
		dh = JSValueToNumber(ctx, argv[4], NULL);
    } else {
        sx = JSValueToNumber(ctx, argv[1], NULL);
        sy = JSValueToNumber(ctx, argv[2], NULL);
		sw = JSValueToNumber(ctx, argv[3], NULL);
		sh = JSValueToNumber(ctx, argv[4], NULL);
		dx = JSValueToNumber(ctx, argv[5], NULL);
		dy = JSValueToNumber(ctx, argv[6], NULL);
		dw = JSValueToNumber(ctx, argv[7], NULL);
		dh = JSValueToNumber(ctx, argv[8], NULL);
    }
	
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	[self drawQuadWithColor:color.hex
		sx:sx sy:sy sw:sw sh:sh
		dx:dx dy:dy dw:dw dh:dh
		flipX:NO flipY:NO];

	return NULL;
}
/* this is just for testing
JS_FUNC(JS_Canvas, switchToThisCanvas, ctx, argc, argv) {
	[self switchToThisCanvas];
	return NULL;
}*/

JS_FUNC(JS_Canvas, getImageData, ctx, argc, argv) {
    if( argc != 4 ) return NULL;
     
    float 
        sx = JSValueToNumber(ctx, argv[0], NULL), 
        sy = JSValueToNumber(ctx, argv[1], NULL), 
        sw = JSValueToNumber(ctx, argv[2], NULL), 
        sh = JSValueToNumber(ctx, argv[3], NULL);
 
	[self flushBuffers:TRUE];

	size_t pixelDataSize = 4 * sw * sh;
 	void * pixelData = malloc( pixelDataSize * sizeof(GL_UNSIGNED_BYTE));
	memset(pixelData, 0x0, pixelDataSize);
 	if(inverted) {
 		glReadPixels (sx, height-sh-sy, sw, sh, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);  // image in buffer in inverted in y direction. 
                                                                                        // Also note that in JS_ImageData the rows are read from the bottom 
	    } else {
        	glReadPixels (sx, sy, sw, sh, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);
	}


	JSStringRef scriptJS = JSStringCreateWithUTF8CString("return new _native.ImageData()");
	// Create an anonymous function and call it 
	JSObjectRef fn = JSObjectMakeFunction(ctx, NULL, 0, NULL, scriptJS, NULL, 1, NULL);
	JSValueRef result = JSObjectCallAsFunction(ctx, fn, NULL, 0, NULL, NULL);
	
	JS_ImageData * imageData = JSObjectGetPrivate(JSValueToObject(ctx, result, NULL));	
	[imageData setWithContext:ctx height:sh width:sw invert:inverted data:pixelData];
	JSStringRelease(scriptJS); 	// Release script 

	return result;
		
}

JS_FUNC(JS_Canvas, drawFont, ctx, argc, argv) {
	if( argc < 5 || !JSValueIsObject(ctx, argv[0]) ) return NULL;
	[self setCurrentTextureFromDrawable:(NSObject<Drawable> *)JSObjectGetPrivate((JSObjectRef)argv[0])];
	
	Font * font = (Font *)currentTexture;
	
	
	float w, h, dx, dy;
	NSString * text = JSValueToNSString(ctx, argv[1]);
	int length = text.length;
	
	dx = JSValueToNumber(ctx, argv[2], NULL) 
		+ [font offsetForText:text withAlignment:JSValueToNumber(ctx, argv[4], NULL)];
	dy = JSValueToNumber(ctx, argv[3], NULL);
	
	h = font.height;
	gl_color color = {.rgba.r=255, .rgba.g=255, .rgba.b=255, .rgba.a=globalAlpha};
	
	for( int i = 0; i < length; i++ ) {
		unichar c = [text characterAtIndex:i];
		
		float x, y;
		[font indexForChar:c x:&x y:&y];
		w = [font widthForChar:c];
		
		[self drawQuadWithColor:color.hex
			sx:x sy:y sw:w sh:h
			dx:dx dy:dy dw:w dh:h
			flipX:NO flipY:NO];
			
		dx += w + FONT_CHAR_SPACING;
	}
	
	return NULL;
}



JS_FUNC(JS_Canvas, save, ctx, argc, argv) {
	[self flushBuffers:FALSE];
	glPushMatrix();
	[canvasPath save];
	return NULL;
}


JS_FUNC(JS_Canvas, restore, ctx, argc, argv) {
	[self flushBuffers:FALSE];
	glPopMatrix();
	[canvasPath restore];
	return NULL;
}


JS_FUNC(JS_Canvas, rotate, ctx, argc, argv) {
	[self flushBuffers:FALSE];
	GLfloat angle=JSValueToNumber(ctx, argv[0], NULL);
	glRotatef(angle*180.0/M_PI, 0, 0, 1);
	[canvasPath rotate:angle];
	return NULL;
}


JS_FUNC(JS_Canvas, translate, ctx, argc, argv) {
	[self flushBuffers:FALSE];
	GLfloat x = JSValueToNumber(ctx, argv[0], NULL), y= JSValueToNumber(ctx, argv[1], NULL);
	glTranslatef(x, y, 0);
	[canvasPath translate:x ty:y];
	return NULL;
}


JS_FUNC(JS_Canvas, scale, ctx, argc, argv) {
	[self flushBuffers:FALSE];
	GLfloat sx=JSValueToNumber(ctx, argv[0], NULL), sy=JSValueToNumber(ctx, argv[1], NULL);
	glScalef(sx, sy, 1);
	[canvasPath scale:sx sy:sy];
	return NULL;
}


JS_FUNC(JS_Canvas, clear, ctx, argc, argv) {
	glClearColor( clearColor[0], clearColor[1], clearColor[2], clearColor[3] );
    glClear(GL_COLOR_BUFFER_BIT);
	return NULL;
}

JS_FUNC(JS_Canvas, fillRect, ctx, argc, argv) {
	[self setCurrentTextureFromDrawable:nil];
	
	float
		dx = JSValueToNumber(ctx, argv[0], NULL),
		dy = JSValueToNumber(ctx, argv[1], NULL),
		w = JSValueToNumber(ctx, argv[2], NULL),
		h = JSValueToNumber(ctx, argv[3], NULL);

//	NSLog(@"fillRect: %f, %f, %f, %f", dx, dy, w, h);
	fillColor.rgba.a = globalAlpha;
	rectDrawMode = DRAWMODE_FILL;
	
	[self drawQuadWithColor:fillColor.hex
		sx:0 sy:0 sw:w sh:h
		dx:dx dy:dy dw:w dh:h
		flipX:NO flipY:NO];
	
	return NULL;
}

JS_FUNC(JS_Canvas, strokeRect, ctx, argc, argv) {
	[self setCurrentTextureFromDrawable:nil];
	float
	dx = JSValueToNumber(ctx, argv[0], NULL),
	dy = JSValueToNumber(ctx, argv[1], NULL),
	w = JSValueToNumber(ctx, argv[2], NULL),
	h = JSValueToNumber(ctx, argv[3], NULL);
	
	strokeColor.rgba.a = globalAlpha;
	rectDrawMode = DRAWMODE_STROKE;
	
	[self drawQuadWithColor:strokeColor.hex
			sx:0 sy:0 sw:w sh:h
			dx:dx dy:dy dw:w dh:h
			flipX:NO flipY:NO];
	
	return NULL;
}

JS_FUNC(JS_Canvas, clearRect, ctx, argc, argv) {
	[self setCurrentTextureFromDrawable:nil];
	
	float
	dx = JSValueToNumber(ctx, argv[0], NULL),
	dy = JSValueToNumber(ctx, argv[1], NULL),
	w = JSValueToNumber(ctx, argv[2], NULL),
	h = JSValueToNumber(ctx, argv[3], NULL);
	
	gl_color clear;
	clear.rgba.r = clearColor[0] * 255.0f;
	clear.rgba.g = clearColor[1] * 255.0f;
	clear.rgba.b = clearColor[2] * 255.0f;
	clear.rgba.a = clearColor[3] * 255.0f;

	rectDrawMode = DRAWMODE_FILL;
	
	[self drawQuadWithColor:clear.hex
						 sx:0 sy:0 sw:w sh:h
						 dx:dx dy:dy dw:w dh:h
					  flipX:NO flipY:NO];
	
	return NULL;
}

//------   Path API   ----------

JS_FUNC(JS_Canvas, beginPath, ctx, argc, argv) {

    [self initializeCanvasPath];
	[canvasPath beginPath];
	return NULL;
}

JS_FUNC(JS_Canvas, closePath, ctx, argc, argv) {
	
    [self initializeCanvasPath];
	[canvasPath closePath];
	return NULL;
}

JS_FUNC(JS_Canvas, moveTo, ctx, argc, argv) {
	
	float
	x = JSValueToNumber(ctx, argv[0], NULL),
	y = JSValueToNumber(ctx, argv[1], NULL);

    [self initializeCanvasPath];
	[canvasPath moveTo:x y:y];
	
	return NULL;
}

JS_FUNC(JS_Canvas, lineTo, ctx, argc, argv) {
	
	float
	x = JSValueToNumber(ctx, argv[0], NULL),
	y = JSValueToNumber(ctx, argv[1], NULL);

    [self initializeCanvasPath];
	[canvasPath lineTo:x y:y];
	
	return NULL;
}

JS_FUNC(JS_Canvas, quadraticCurveTo, ctx, argc, argv) {
	
	float
	cpx = JSValueToNumber(ctx, argv[0], NULL),
	cpy = JSValueToNumber(ctx, argv[1], NULL), 
	x = JSValueToNumber(ctx, argv[2], NULL), 
	y = JSValueToNumber(ctx, argv[3], NULL); 
	
    [self initializeCanvasPath];
	[canvasPath quadraticCurveTo:cpx cpy:cpy x:x y:y];	
	return NULL;
}

JS_FUNC(JS_Canvas, bezierCurveTo, ctx, argc, argv) {
	
	float
	cp1x = JSValueToNumber(ctx, argv[0], NULL),
	cp1y = JSValueToNumber(ctx, argv[1], NULL), 
	cp2x = JSValueToNumber(ctx, argv[2], NULL), 
	cp2y = JSValueToNumber(ctx, argv[3], NULL), 
	x = JSValueToNumber(ctx, argv[4], NULL), 
	y = JSValueToNumber(ctx, argv[5], NULL);
	
    [self initializeCanvasPath];
	[canvasPath bezierCurveTo:cp1x cp1y:cp1y cp2x:cp2x cp2y:cp2y x:x y:y];
	return NULL;
}

JS_FUNC(JS_Canvas, arcTo, ctx, argc, argv) {
	
	float
	x0 = JSValueToNumber(ctx, argv[0], NULL),
	y0 = JSValueToNumber(ctx, argv[1], NULL), 
	x1 = JSValueToNumber(ctx, argv[2], NULL), 
	y1 = JSValueToNumber(ctx, argv[3], NULL), 
	r = JSValueToNumber(ctx, argv[4], NULL); 
	int error=0;
	
    [self initializeCanvasPath];
	[canvasPath arcTo:x0 y0:y0 x1:x1 y1:y1 r:r exceptionCode:&error];
	return NULL;
}

JS_FUNC(JS_Canvas, arc, ctx, argc, argv) {
	
	float
	x = JSValueToNumber(ctx, argv[0], NULL),
	y = JSValueToNumber(ctx, argv[1], NULL), 
	r = JSValueToNumber(ctx, argv[2], NULL), 
	sa = JSValueToNumber(ctx, argv[3], NULL), 
	ea = JSValueToNumber(ctx, argv[4], NULL), 
	anticlockwise = JSValueToNumber(ctx, argv[5], NULL);
	int error=0;
	
    [self initializeCanvasPath];
	[canvasPath arc:x y:y r:r sa:sa ea:ea acl:anticlockwise exceptionCode:&error];
	return NULL;
}

JS_FUNC(JS_Canvas, rect, ctx, argc, argv) {
	
	float
	x = JSValueToNumber(ctx, argv[0], NULL),
	y = JSValueToNumber(ctx, argv[1], NULL), 
	width_ = JSValueToNumber(ctx, argv[2], NULL), 
	height_ = JSValueToNumber(ctx, argv[3], NULL);
	
    [self initializeCanvasPath];
	[canvasPath rect:x y:y width:width_ height:height_];
	return NULL;
}


JS_FUNC(JS_Canvas, fill, ctx, argc, argv) {
	
    [self initializeCanvasPath];
	[canvasPath fill];
	pathIsModified = TRUE;
//	[self drawPath];

	return NULL;
}

JS_FUNC(JS_Canvas, stroke, ctx, argc, argv) {
	
    [self initializeCanvasPath];
	[canvasPath stroke];
	pathIsModified = TRUE;
//	[self drawPath];

	return NULL;
}

JS_FUNC(JS_Canvas, isPointInPath, ctx, argc, argv) {
	
	float
	x = JSValueToNumber(ctx, argv[0], NULL),
	y = JSValueToNumber(ctx, argv[1], NULL);
	
    [self initializeCanvasPath];
	[canvasPath isPointInPath:x y:y];
	return NULL;
}

// just for temp testing, remove later
JS_FUNC(JS_Canvas, testFunction, ctx, argc, argv) {
    [self initializeCanvasPath];
	[canvasPath clear];
	return NULL;
}

//--------------------------------- 

JS_GET(JS_Canvas, fillStyle, ctx ) {
	return JSValueMakeNumber(ctx, 0 ); // FIXME: stub
}

JS_SET(JS_Canvas, fillStyle, ctx, value) {
	fillColor = JSValueToColor( ctx, value );
    [self initializeCanvasPath];
	[canvasPath setFillColor:fillColor.rgba.r/255.f g:fillColor.rgba.g/255.f b:fillColor.rgba.b/255.f a:fillColor.rgba.a/255.f];
}

JS_GET(JS_Canvas, clearStyle, ctx ) {
	return JSValueMakeNumber(ctx, 0 ); // FIXME: stub
}

JS_SET(JS_Canvas, clearStyle, ctx, value) {
	gl_color c = JSValueToColor( ctx, value );
	clearColor[0] = c.rgba.r / 255.0f;
	clearColor[1] = c.rgba.g / 255.0f;
	clearColor[2] = c.rgba.b / 255.0f;
	clearColor[3] = c.rgba.a / 255.0f;
}

JS_GET(JS_Canvas, strokeStyle, ctx ) {
	return JSValueMakeNumber(ctx, 0 ); // FIXME: stub
}

JS_SET(JS_Canvas, strokeStyle, ctx, value) {
	strokeColor = JSValueToColor( ctx, value );
    [self initializeCanvasPath];
	[canvasPath setStrokeColor:strokeColor.rgba.r/255.f g:strokeColor.rgba.g/255.f b:strokeColor.rgba.b/255.f a:strokeColor.rgba.a/255.f];
}

JS_GET(JS_Canvas, globalAlpha, ctx ) {
	return JSValueMakeNumber(ctx, globalAlpha/255.0f );
}

JS_SET(JS_Canvas, globalAlpha, ctx, value) {
	globalAlpha = MIN(255,MAX(JSValueToNumber(ctx, value, NULL)*255,0));
}

JS_GET(JS_Canvas, globalCompositeOperation, ctx) {
	// FIXME: stub
	JSStringRef s = JSStringCreateWithUTF8CString("source-over");
	JSValueRef ret = JSValueMakeString(ctx, s);
	JSStringRelease(s);
	return ret;
}

JS_SET(JS_Canvas, globalCompositeOperation, ctx, value) {
	if( !JSValueIsString(ctx, value) ) return;
	
	[self flushBuffers:FALSE];
	
	// Just check for the length of the string to determine the blend mode
	// This is a cheap hack... FIXME
	int length = JSStringGetLength( (JSStringRef)value ) + 1;
	if( length == sizeof("lighter") ) {
		glBlendFunc(GL_ONE, GL_ONE);
	}
	else if( length == sizeof("darker") ) {
		glBlendFunc(GL_ZERO, GL_SRC_COLOR);
	}
	else { // source-over
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
}

JS_FUNC(JS_Canvas, getContext, ctx, argc, argv) {
	// Context and canvas are one and the same object, so getContext just
	// returns itself
	return (JSValueRef)object;
}

JS_GET(JS_Canvas, width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

JS_SET(JS_Canvas, width, ctx, value) {
	width = JSValueToNumber(ctx, value, NULL);
	[self setglDimentionsWithWidth:width Height:height Scale:scale];
}

JS_GET(JS_Canvas, height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

JS_SET(JS_Canvas, height, ctx, value) {
	height = JSValueToNumber(ctx, value, NULL);
	if(height<9)  // createFramebuffer fails on iPad if height<9 !
        	height=9;
	[self setglDimentionsWithWidth:width Height:height Scale:scale];
}
@end
