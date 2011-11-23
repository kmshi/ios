
#import <UIKit/UIKit.h>
#import "AppMobiCommand.h"



@interface AppMobiAccelerometer : AppMobiCommand<UIAccelerometerDelegate>
{
	bool _bIsRunning;

}

- (void)start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end


