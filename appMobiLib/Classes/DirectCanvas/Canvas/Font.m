#import "Font.h"


@implementation Font

- (id)initWithPath:(NSString *)path {
	if( self = [super init] ) {		
		GLubyte * pixels = [self loadImageFromPath:path];
		
		// We don't need to draw the last row of pixels
		height = height - 1; 
		
		// Find the width and x position of each character in the font bitmap
		int currentChar = 0;
		int currentWidth = 0;
		int firstPixelOnLastRow = height * realWidth * 4;
		int indices[FONT_MAX_CHARS];
		int x;
		for( x = 0; x < width && currentChar < FONT_MAX_CHARS-1; x++ ) {
			int index = firstPixelOnLastRow + x * 4 + 3; // alpha component of this pixel
			if( pixels[index] != 0 ) {
				currentWidth++;
			}
			else if( pixels[index] == 0 && currentWidth ) {
				widthMap[currentChar] = currentWidth;
				indices[currentChar] = x - currentWidth;
				currentChar++;
				currentWidth = 0;
				
			}
		}
		widthMap[currentChar] = currentWidth;
		indices[currentChar] = x - currentWidth;
		
		glGenTextures(1, &textureId);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		GLint maxTextureSize;
		glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maxTextureSize );
		
		// If the width of the font bitmap is larger than maxTextureSize,
		// we have to re-order the characters into several rows of maxTextureSize
		if( realWidth > maxTextureSize ) {
			int oldRealWidth = realWidth;
			realHeight = pow(2, ceil(log2( (realWidth/maxTextureSize)*height )));
			realWidth = maxTextureSize;
			
			GLubyte * newPixels = (GLubyte *) malloc( realWidth * realHeight * 4);
			memset( newPixels, 0, realWidth * realHeight * 4 );
			
			int x = 0, y = 0;
			for( int i = 0; i < FONT_MAX_CHARS; i++ ) {
				int w = widthMap[i]; 
				if( x + w > maxTextureSize ) {
					x = 0;
					y += height;
				}
				
				// Transfer char into the new pixel array
				int oldpx = indices[i];
				int newpx = (y * realWidth + x );
				for( int ry = 0; ry < height; ry++ ) {
					for( int rx = 0; rx < w; rx++ ) {
						((uint32_t *)newPixels)[newpx] = ((uint32_t *)pixels)[oldpx];
						oldpx++;
						newpx++;
					}
					oldpx += oldRealWidth - w;
					newpx += realWidth - w;
				}
				
				// Remember the new position
				indices2d[i][0] = x;
				indices2d[i][1] = y;
				x += w;
			}
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, newPixels);
			free(newPixels);
		}
		
		// Smaller than maxTextureSize? Just use the original font bitmap!
		else {
			for( int i = 0; i < FONT_MAX_CHARS; i++ ) {
				indices2d[i][0] = indices[i];
				indices2d[i][1] = 0;
			}
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, realWidth, realHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		}
		
		free(pixels);
	}
	
	return self;
}


- (float)offsetForText:(NSString *)text withAlignment:(int)align {
	if( align == FONT_ALIGN_LEFT ) {
		return 0;
	}
	
	float w = 0;
	int length = text.length;
	for( int i = 0; i < length; i++ ) {
		unichar c = [text characterAtIndex:i] - FONT_FIRST_CHAR;
		w += (c < FONT_MAX_CHARS ? widthMap[c] + FONT_CHAR_SPACING : 0);
	}
	return align == FONT_ALIGN_RIGHT ? -w : -w/2;
}


- (float)widthForChar:(unichar)c {
	c -= FONT_FIRST_CHAR;
	if( c > FONT_MAX_CHARS ) {
		c = 0;
	}
	
	return widthMap[c];
}


- (void)indexForChar:(unichar)c x:(float *)x y:(float *)y {
	c -= FONT_FIRST_CHAR;
	if( c > FONT_MAX_CHARS ) {
		c = 0;
	}
	*x = indices2d[c][0];
	*y = indices2d[c][1];
}


@end
