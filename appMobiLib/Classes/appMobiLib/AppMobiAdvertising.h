//
//  AppMobiAdvertising.h
//  appLab
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"

@interface AppMobiAdvertising : AppMobiCommand {	

}

- (void)getAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)showFullscreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)hideFullscreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
	
@end


