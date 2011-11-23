#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"

@interface JS_Button : JS_BaseClass {
	UIButton * button;
	JSObjectRef callbackUp, callbackDown;
	UIDeviceOrientation orientation;
	
	CGFloat x, y, w, h;
}

- (void)layoutAccordingToOrientation;

@end
