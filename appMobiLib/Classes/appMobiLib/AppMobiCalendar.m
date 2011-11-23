//
//  AppMobiCalendar.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiCalendar.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"
#import "AppConfig.h"
#import <EventKit/EventKit.h>
#import "AppMobiWebView.h"

@implementation AppMobiCalendar

- (void)addEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	//AppMobiDelegate *delegate = [AppMobiDelegate sharedDelegate];
	
	NSString *evtTitle = (NSString *)[arguments objectAtIndex:0];
	NSString *beginDate = (NSString *)[arguments objectAtIndex:1];
	NSString *endDate = (NSString *)[arguments objectAtIndex:2];
	NSString *success = @"false";
	
	@try
	{
		EKEventStore *eventStore = [[EKEventStore alloc] init];
		
		EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
		event.title     = evtTitle;
		
		NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
		[inFormat setDateFormat:@"MMM dd, yyyy"];
		
		NSDate *bg_Date  = [inFormat dateFromString:beginDate];		
		NSDate *end_Date = [inFormat dateFromString:endDate];
		
		event.startDate = bg_Date;
		event.endDate   = end_Date;
		
		NSError *err;
		[event setCalendar:[eventStore defaultCalendarForNewEvents]];
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
		if( err == noErr ) success = @"true";
	}
	@catch (NSException *exception)
	{
		success = @"false";
	}
	
	// Maybe you want to fire an event to the web view when it's started	
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.calendar.event.add',true,true);e.success=%@;document.dispatchEvent(e);", success];
	AMLog(@"%@",js);
	[webView injectJS:js];
}

- (void) dealloc
{
	[super dealloc];
}

@end
