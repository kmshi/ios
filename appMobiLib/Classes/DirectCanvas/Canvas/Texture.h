#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface Texture : NSObject {
	int width, height, realWidth, realHeight;
	GLuint textureId;
}
- (id)initWithPath:(NSString *)path;
- (GLubyte *)loadImageFromPath:(NSString *)path;
- (id)initWithWidth:(int)widthp height:(int)heightp;
- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *) pixels;
- (void)bind;
-(void) texImage:(GLubyte *)pixels;

@property (readonly) GLuint textureId;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int realWidth;
@property (readonly) int realHeight;

@end
