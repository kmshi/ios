
//
//  AppMobiStats.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiStats.h"
#import "AppConfig.h"
#import "AppMobiWebView.h"
#import "TargetConditionals.h"

@implementation AppMobiStats

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiStats *) [super initWithWebView:webview];
	
	return self;
}

- (void)logEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasAnalytics) return;
	
	// error deprecated
}

- (void) dealloc
{
	[super dealloc];
}

@end
