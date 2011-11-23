//
//  PhoneGapCommand.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppMobiCommand.h"

@interface PhoneGapCommand : AppMobiCommand {
}

- (id<UIApplicationDelegate>) appDelegate;
- (UIViewController *)appViewController;

- (void)injectJS:(NSString *)javascript;

@end
