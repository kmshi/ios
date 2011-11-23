//
//  AppMobiTestAppDelegate.h
//  AppMobiTest
//

//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppMobiDelegate.h"

@class LoginViewController;

@interface AppDelegate : AppMobiDelegate {
	LoginViewController *loginViewController;
}

@property (nonatomic, retain) LoginViewController *loginViewController;

@end

