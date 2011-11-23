#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"

@interface JS_TouchInput : JS_BaseClass <TouchDelegate> {
	JSObjectRef callbackStart, callbackEnd, callbackMove;
	BOOL landscapeMode;
}

- (void)invokeCallback:(JSObjectRef)callback withTouches:(NSSet *)touches;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end
