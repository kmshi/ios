#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Texture.h"
#import "DirectCanvas.h"

@implementation Texture
@synthesize textureId;
@synthesize width;
@synthesize height;
@synthesize realWidth;
@synthesize realHeight;

- (id)initWithPath:(NSString *)path {
	if( self = [super init] ) {		
		GLubyte * pixels = [self loadImageFromPath:path];
		
		bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
		int boundTexture = 0;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
		
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
		glBindTexture(GL_TEXTURE_2D, boundTexture);
		if( !wasEnabled ) {
			glDisable(GL_TEXTURE_2D);
		}
		
		free(pixels);
	}

	return self;
}

CGImageRef CreateScaledCGImageFromCGImage(CGImageRef image, float scale)
{
	// Create the bitmap context
	CGContextRef    context = NULL;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	int width = CGImageGetWidth(image) * scale;
	int height = CGImageGetHeight(image) * scale;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (width * 4);
	bitmapByteCount     = (bitmapBytesPerRow * height);
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		return nil;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
									 colorspace,kCGImageAlphaNoneSkipFirst);
	CGColorSpaceRelease(colorspace);
	
	if (context == NULL)
		// error creating context
		return nil;
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
	
	CGImageRef imgRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	free(bitmapData);
	
	return imgRef;
}

- (GLubyte *)loadImageFromPath:(NSString *)path {
	UIImage * tmpImage = nil;//(bool)[path hasSuffix:@"icon.png"]
    
    if([path hasPrefix:@"http"]) {
        NSURL * imgURL = [NSURL URLWithString:path];
        NSData * imgData = [NSData dataWithContentsOfURL:imgURL];
        tmpImage = [[UIImage alloc] initWithData:imgData];
    } else {
        tmpImage = [[UIImage alloc] initWithContentsOfFile:path];
    }
	CGImageRef image = tmpImage.CGImage;
	/*
	CGImageRef imageOrig = tmpImage.CGImage;
	CGImageRef image = CreateScaledCGImageFromCGImage(imageOrig, 0.6);
	[tmpImage release];
	*/
	
	width = CGImageGetWidth(image);
	height = CGImageGetHeight(image);
	
	realWidth = pow(2, ceil(log2( width )));
	realHeight = pow(2, ceil(log2( height )));
	
	GLubyte * pixels = (GLubyte *) malloc( realWidth * realHeight * 4); //:Note: in iOS 4, can pass NULL to let iOS allocate the memory
	memset( pixels, 0, realWidth * realHeight * 4 );
	//use generic colorspace
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	//CGContextRef context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
	CGContextRef context = CGBitmapContextCreate(pixels, realWidth, realHeight, 8, realWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, CGRectMake(0.0, realHeight - height, (CGFloat)width, (CGFloat)height), image);
	CGContextRelease(context);
	
	//CGImageRelease(image);
	
	[tmpImage release];
	return pixels;	
}



- (id)initWithWidth:(int)widthp height:(int)heightp {
	//: TODO: call the following function with null for pixels instead of this impl
	if( self = [super init] ) {
		width = widthp;
		height = heightp;
		
		realWidth = pow(2, ceil(log2( width )));
		realHeight = pow(2, ceil(log2( height )));
		
		bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
		int boundTexture = 0;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
		
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		glBindTexture(GL_TEXTURE_2D, boundTexture);
		if( !wasEnabled ) {
			glDisable(GL_TEXTURE_2D);
		}
	}
	return self;
}

- (id)initWithWidth:(int)widthp height:(int)heightp pixels:(GLubyte *) pixels {
	if( self = [super init] ) {
		width = widthp;
		height = heightp;
		
		realWidth = pow(2, ceil(log2( width )));
		realHeight = pow(2, ceil(log2( height )));
		
		bool wasEnabled = glIsEnabled(GL_TEXTURE_2D);
		int boundTexture = 0;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &boundTexture);
		
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		glBindTexture(GL_TEXTURE_2D, boundTexture);
		if( !wasEnabled ) {
			glDisable(GL_TEXTURE_2D);
		}
	}
	return self;
}


- (void)bind {
	glBindTexture(GL_TEXTURE_2D, textureId);
}

-(void) texImage:(GLubyte *) pixels 
{
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
}

- (void)dealloc {
	glDeleteTextures( 1, &textureId );
	[super dealloc];
}

@end
