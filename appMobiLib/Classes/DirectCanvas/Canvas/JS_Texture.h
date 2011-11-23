#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#import "Texture.h"
#import "Drawable.h"

@interface JS_Texture : JS_BaseClass <Drawable> {
	NSString * path;
	Texture * texture;
    int framewidth;
    int frameheight;
}

@property (readonly) Texture * texture;
@property (readonly) NSString * path;
@property (readonly) int framewidth;
@property (readonly) int frameheight;

@end
