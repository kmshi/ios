//
//  AMSNotification.m
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AMSNotification.h"

@implementation AMSNotification

@synthesize ident, data, userkey, message, target, url, richhtml, richurl, isrich, hidden;

- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[data release];
	[userkey release];
	[message release];
	[target release];
	[url release];
	[richhtml release];
	[richurl release];
	[super dealloc];
}

@end
