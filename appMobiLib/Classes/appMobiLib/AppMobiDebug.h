//
//  DebugConsole.h
//  AppMobi
//
//  Created by Michael Nachbaur on 14/03/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppMobiCommand.h"

@interface AppMobiDebug : AppMobiCommand {
}

- (void)log:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
