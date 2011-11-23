//
//  DebugConsole.m
//  AppMobi
//
//  Created by Michael Nachbaur on 14/03/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "AppMobiDebug.h"
#import "AppMobiDelegate.h"

@implementation AppMobiDebug

- (void)log:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* message = [arguments objectAtIndex:0];
    NSString* log_level = @"INFO";
    if ([options objectForKey:@"logLevel"])
        log_level = [options objectForKey:@"logLevel"];

    AMLog(@"[%@] %@", log_level, message);
}

@end
