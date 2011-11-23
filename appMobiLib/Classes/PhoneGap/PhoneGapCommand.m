//
//  PhoneGapCommand.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "PhoneGapCommand.h"
#import "AppMobiWebView.h"
#import "AppMobiDelegate.h"

@implementation PhoneGapCommand

- (void)dealloc
{
    [super dealloc];
}

- (id<UIApplicationDelegate>)appDelegate
{
	return [AppMobiDelegate sharedDelegate];
}

- (UIViewController *)appViewController
{
	return (UIViewController *) [AppMobiDelegate sharedDelegate].viewController;
}

- (void)injectJS:(NSString *)javascript
{	
	[webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:javascript waitUntilDone:NO];
}

@end