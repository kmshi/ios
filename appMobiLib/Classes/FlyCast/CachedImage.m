
#import <UIKit/UIKit.h>
#import "CachedImage.h"

@implementation CachedImage

@synthesize image = _image;
@synthesize url = _url;

- (id)init
{
	self = [super init];
	_url = nil;
	_image = nil;
	return self;
}

- (void)dealloc
{
	if( _url != nil ) [_url release];
	if( _image != nil ) [_image release];
	[super dealloc];
}

@end
