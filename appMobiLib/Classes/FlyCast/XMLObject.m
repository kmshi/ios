
#import "XMLObject.h"

@implementation XMLObject

@synthesize type;
@synthesize children = _children;

- (id)init
{
	self = [super init];
	type = NONE;
	_children = nil;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

- (id)initWithCoder:(NSCoder *)coder
{
	type = NONE;
	_children = nil;
	return self;
}
- (void)dealloc
{
	if( _children != nil ) [_children release];
	[super dealloc];
}

@end
