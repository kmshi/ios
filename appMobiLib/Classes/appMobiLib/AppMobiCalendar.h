//
//  AppMobiCalendar.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"

@interface AppMobiCalendar : AppMobiCommand {
}

- (void)addEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
