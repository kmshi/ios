#import <Foundation/Foundation.h>
#import "JS_BaseClass.h"


@interface JS_AppMobi : JS_BaseClass {
	int uniqueId;
	NSMutableDictionary * timers;
	NSDate * pauseTime;
	NSMutableDictionary * timerTimes;
	
	NSString * urlToOpen;
}

- (JSValueRef)createTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv repeat:(BOOL)repeat;
- (JSValueRef)deleteTimer:(JSContextRef)ctx argc:(size_t)argc argv:(const JSValueRef [])argv;

@end
