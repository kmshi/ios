#import "JS_Font.h"


@implementation JS_Font

@synthesize texture;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		path = [JSValueToNSString( ctx, argv[0] ) retain];
		texture = [[Font alloc] initWithPath:[DirectCanvas pathForResource:path]];
		
		NSLog(@"Loading Font: %@", path );
		
		if( texture.textureId ) {
			JSObjectRef func = JSValueToObject(ctx, argv[1], NULL);
			JSValueRef params[] = {
				JSValueMakeNumber(ctx, texture.width),
				JSValueMakeNumber(ctx, texture.height)
			};
			[[DirectCanvas instance] invokeCallback:func thisObject:NULL argc:2 argv:params];
		}
	}
	return self;
}

- (void)dealloc {
	[texture release];
	[path release];
	[super dealloc];
}

@end
