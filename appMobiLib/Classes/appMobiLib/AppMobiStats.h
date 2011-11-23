//
//  AppMobiStats.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"

@interface AppMobiStats : AppMobiCommand
{
}

- (void)logEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
