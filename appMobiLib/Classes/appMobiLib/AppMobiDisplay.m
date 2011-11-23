
#import "AppMobiDisplay.h"
#import "AppMobiViewController.h"

@implementation AppMobiDisplay

- (void)startAR:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{	
	AppMobiViewController *vc = [AppMobiViewController masterViewController];
	[vc showCamera:nil];
}

- (void)stopAR:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	AppMobiViewController *vc = [AppMobiViewController masterViewController];
	[vc hideCamera:nil];
}

@end
