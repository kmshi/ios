#import "JS_ImageData.h"


@implementation JS_ImageData

@synthesize imageData;


- (id) setWithContext:(JSContextRef)ctx height:(unsigned long)height width:(unsigned long)width invert:(BOOL)invert data:(Byte *)dataBytes  {
	
	//NSLog(@"Setup JS_ImageData");
	int length = height*width*4;
	JSValueRef* val = (JSValueRef*) malloc(length*sizeof(JSValueRef));
	int count=0;
	int j=0, inc=1;
	if(invert) {		// reverse the rows
		j=height-1;
		inc=-1;
	}
	for(int rows=0; rows<height; rows++) {  
		for(int i=0; i<width*4; i++) {
			val[count]=JSValueMakeNumber(ctx, dataBytes[i+j*width*4]);
			JSValueProtect(ctx, val[count]);
			count++;
		}
		j+=inc;
	}
	
	//: hack! - make alpha 0 if rgb=0.  This is to make impact's font.js work
	// remove this if can modify opengl compositing to keep the original rgba instead of multiplying by alpha
	// merge this loop into the loop above to make it more optimized
	JSValueRef valZero=JSValueMakeNumber(ctx,0);
	for(int i=0; i<width*height*4; i+=4) {
        int r = dataBytes[i];
        int g = dataBytes[i+1];
        int b = dataBytes[i+2];
		if(r==0 && g==0 && b==0) val[i+3]=valZero;
	}
	// end of hack!
	
	data = JSObjectMakeArray(ctx, length, (JSValueRef*) val, NULL);
	
	for(count=0; count<length; count++)
		JSValueUnprotect(ctx, val[count]);
	free(val);
	
	imageData = [[ImageData alloc] initWithHeight:height width:width];
	
	return NULL; 
}


// This makes a constructor for ImageData in JS.  We don't use the arguments since we'll set them later
- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	
	self  = [super initWithContext:ctx object:obj argc:argc argv:argv];
	return self;
}

- (void)dealloc {
	[imageData release];
	[super dealloc];
}


JS_GET(JS_ImageData, width, ctx) {
	return JSValueMakeNumber(ctx, imageData.width);
}

JS_GET(JS_ImageData, height, ctx) {
	return JSValueMakeNumber(ctx, imageData.height);
}

JS_GET(JS_ImageData, data, ctx) {
	return data;
}

@end

