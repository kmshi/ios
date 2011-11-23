//
//  AMSResponse.m
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AMSResponse.h"

@implementation AMSPurchase

@synthesize app, rel, url, authorized, installed;


- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[app release];
	[rel release];
	[url release];
	[super dealloc];
}

@end

@implementation AMSResponse

@synthesize name, result, message, email, user, notifications, purchases;


- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[name release];
	[result release];
	[message release];
	[email release];
	[user release];
	[notifications release];
	[purchases release];
	[super dealloc];
}

@end
