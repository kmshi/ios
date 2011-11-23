#import "JS_Texture.h"


@implementation JS_Texture

@synthesize texture, framewidth, frameheight, path;

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self  = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		path = [JSValueToNSString( ctx, argv[0] ) retain];
        NSString * fullPath = [[DirectCanvas pathForResource:path] retain];
		texture = [[Texture alloc] initWithPath:fullPath];
		NSLog(@"Loading Image: %@", fullPath );
        [fullPath release];
		
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

JS_FUNC(JS_Texture, SetFrameSize, ctx, argc, argv ) {
    
	if(argc<2)
		return NULL;
    
	int w = JSValueToNumber(ctx, argv[0], NULL);
	int h = JSValueToNumber(ctx, argv[1], NULL);
	
	framewidth = w;
    frameheight = h;
	
	return NULL;
}

@end
