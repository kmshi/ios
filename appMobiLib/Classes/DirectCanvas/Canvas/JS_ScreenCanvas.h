#import <Foundation/Foundation.h>
#import "JS_Canvas.h"

@interface JS_ScreenCanvas : JS_Canvas {
	EAGLView * glview;
	BOOL landscapeMode;
	UIDeviceOrientation orientation;
    
    NSTimer * timer;
    NSLock * lock;
	float requestedScale;
	double calculatedScale;
}

- (void)orientationChange:(NSNotification *)notification;
- (void)autoPresent:(NSTimer*)timer;
- (BOOL)present;
- (void)setFPS:(NSNumber*)fps;
- (void)doScale:(float)gScale;
@end
