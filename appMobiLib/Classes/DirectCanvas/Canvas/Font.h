#import <Foundation/Foundation.h>
#import "Texture.h"

#define FONT_FIRST_CHAR 32
#define FONT_MAX_CHARS 128
#define FONT_CHAR_SPACING 1

#define FONT_ALIGN_LEFT 0
#define FONT_ALIGN_RIGHT 1
#define FONT_ALIGN_CENTER 2

@interface Font : Texture {
	int widthMap[FONT_MAX_CHARS];
	int indices2d[FONT_MAX_CHARS][2];
}

- (float)offsetForText:(NSString *)text withAlignment:(int)align;
- (float)widthForChar:(unichar)c;
- (void)indexForChar:(unichar)c x:(float *)x y:(float *)y;

@end