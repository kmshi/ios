
#import <UIKit/UIKit.h>
#import "AppMobiCommand.h"

@interface AppMobiDisplay : AppMobiCommand
{
}

- (void)startAR:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stopAR:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end


