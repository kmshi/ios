/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Created by Michael Nachbaur on 13/04/09.
 * Copyright (c) 2009 Decaf Ninja Software. All rights reserved.
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 * Copyright (c) 2010, IBM Corporation
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PluginResult.h"
#import "NSMutableArray+QueueAdditions.h"
#import "AppMobiCommand.h" // [appMobi added] 

#define PGPluginHandleOpenURLNotification	@"PGPluginHandleOpenURLNotification"

#define VERIFY_ARGUMENTS(args, expectedCount, callbackId) if (![self verifyArguments:args withExpectedCount:expectedCount andCallbackId:callbackId \
callerFileName:__FILE__ callerFunctionName:__PRETTY_FUNCTION__]) { return; }


// [appMobi removed] @class PhoneGapDelegate;
@class AppMobiDelegate; // [appMobi added]

// [appMobi removed] @interface PGPlugin : NSObject {
@interface PGPlugin : AppMobiCommand { // [appMobi added]
}

// [appMobi removed] @property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSDictionary *settings;

- (PGPlugin*) initWithWebView:(UIWebView*)theWebView settings:(NSDictionary*)classSettings;
- (PGPlugin*) initWithWebView:(UIWebView*)theWebView;

- (void) handleOpenURL:(NSNotification*)notification;
- (void) onAppTerminate;
- (void) onMemoryWarning;

/*
 // see initWithWebView implementation
 - (void) onPause {}
 - (void) onResume {}
 - (void) onOrientationWillChange {}
 - (void) onOrientationDidChange {}
 */

// [appMobi removed] - (PhoneGapDelegate*) appDelegate;
- (AppMobiDelegate*) appDelegate; // [appMobi added]
- (UIViewController*) appViewController;

- (NSString*) writeJavascript:(NSString*)javascript;
- (BOOL) verifyArguments:(NSMutableArray*)arguments withExpectedCount:(NSUInteger)expectedCount andCallbackId:(NSString*)callbackId 
		  callerFileName:(const char*)callerFileName callerFunctionName:(const char*)callerFunctionName;

@end
