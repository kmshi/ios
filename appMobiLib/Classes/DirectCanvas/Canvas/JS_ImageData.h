#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"
#import "ImageData.h"

//http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#imagedata

/*
 interface CanvasPixelArray {
 readonly attribute unsigned long length;
 getter octet (in unsigned long index);
 setter void (in unsigned long index, in octet value);
 };
 */


/*
 interface ImageData {
 readonly attribute unsigned long width;
 readonly attribute unsigned long height;
 readonly attribute CanvasPixelArray data;
 };     
 */

@interface JS_ImageData : JS_BaseClass {
	
	ImageData *imageData;
	JSObjectRef data;   // This implements the data attribute, but CanvasPixelArray is not explicitly created.
}

@property (readonly) ImageData * imageData;

- (id) setWithContext:(JSContextRef)ctx height:(unsigned long)height width:(unsigned long)width invert:(BOOL)invert data:(Byte *)dataBytes;

@end