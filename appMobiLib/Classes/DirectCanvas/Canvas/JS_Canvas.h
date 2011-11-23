#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"

#import "Texture.h"
#import "Font.h"
#import "Drawable.h"
#import "CanvasPath.h"
#import "EAGLView.h"

#import "JS_ImageData.h"

//#define USE_DRAW_ELEMENTS

#ifdef USE_DRAW_ELEMENTS
    #define CANVAS_CONTEXT_BUFFER_SIZE 64 // to hold index in one byte
#else
    #define CANVAS_CONTEXT_BUFFER_SIZE 128
#endif

typedef union tag_gl_color { 
	struct tag_color { 
		GLubyte r,g,b,a;
	} rgba;
	GLuint hex; 
} gl_color;

enum drawMode {
	DRAWMODE_FILL,
	DRAWMODE_STROKE
};

gl_color JSValueToColor(JSContextRef ctx, JSValueRef value);


@interface JS_Canvas : JS_BaseClass <Drawable> {
	int width;
	int height;
	double scale;
    BOOL inverted;
	
	Texture * texture;
	Texture * currentTexture;
	CanvasPath * canvasPath;
	
	int quadIndex;
	int drawCalls;
	enum drawMode rectDrawMode, lastRectDrawMode;
	BOOL pathIsModified;
	
	gl_color fillColor, strokeColor;
	float clearColor[4];
	GLubyte globalAlpha;
    
#ifdef USE_DRAW_ELEMENTS	
	GLfloat quadVertices[CANVAS_CONTEXT_BUFFER_SIZE][8];
	GLfloat textureVertices[CANVAS_CONTEXT_BUFFER_SIZE][8];
	GLubyte vertexColors[CANVAS_CONTEXT_BUFFER_SIZE][24];
#else
	GLfloat quadVertices[CANVAS_CONTEXT_BUFFER_SIZE][12];
	GLfloat textureVertices[CANVAS_CONTEXT_BUFFER_SIZE][12];
	GLubyte vertexColors[CANVAS_CONTEXT_BUFFER_SIZE][24];
#endif
}
- (void) setglDimentionsWithWidth:(int)_width Height:(int)_height Scale:(float)_scale;
- (void)setFrameBuffer;
- (void)prepareThisCanvas;
- (void)switchToThisCanvas;
- (void)flushBuffers:(BOOL) drawPath;
- (void)setCurrentTextureFromDrawable:(NSObject<Drawable> *)drawable;
- (void)drawQuadWithColor:(GLuint)color
	sx:(float)sx sy:(float)sy sw:(float)sw sh:(float)sh
	dx:(float)dx dy:(float)dy dw:(float)dw dh:(float)dh
	flipX:(BOOL)flipX flipY:(float)flipY;
- (void) drawPath;
	
@property (readonly) Texture * texture;

@end
