/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 * 
 * Copyright (c) 2005-2010, Nitobi Software Inc.
 */


#import "PGSplashScreen.h"
// [appMobi removed] #import "PhoneGapDelegate.h"
#import "AppMobiDelegate.h" // [appMobi added]

@implementation PGSplashScreen


- (void) __show:(BOOL)show
{
	// [appMobi removed]
	/* Because PhoneGap is running in our container the view hierarchy is
	 * different and these objects won't exist. Mapping calls to similiar
	 * functions in the appMobi namespace.

	PhoneGapDelegate* delegate = [super appDelegate];
	if (!delegate.imageView) {
		return;
	}
	
	delegate.imageView.hidden = !show;
	delegate.activityView.hidden = !show;
	//*/
}

- (void) show:(NSArray*)arguments withDict:(NSMutableDictionary*)options
{
	// [appMobi removed] [self __show:YES];
}

- (void) hide:(NSArray*)arguments withDict:(NSMutableDictionary*)options
{
	// [appMobi removed] [self __show:NO];
	
	// [appMobi added]
	AppMobiDelegate *delegate = [AppMobiDelegate sharedDelegate];	
	if( delegate && [delegate respondsToSelector:@selector(hideSplashScreen:)] )
	{
		[delegate performSelectorOnMainThread:@selector(hideSplashScreen:) withObject:nil waitUntilDone:NO];
	}
}

@end
