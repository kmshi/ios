#import <Foundation/Foundation.h>
#import "Font.h"
#import "JS_BaseClass.h"
#import "Drawable.h"

@interface JS_Font : JS_BaseClass <Drawable> {
	NSString * path;
	Font * texture;
}

@property (readonly) Texture * texture;

@end
