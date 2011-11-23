//
//  AppMobiResponse.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiResponse.h"

@implementation AppMobiResponse

@synthesize event, message, result, identifier;
@synthesize state;
@synthesize success;

- (void) dealloc
{
	[event release];
	[message release];
	[result release];
	[identifier release];
	[super dealloc];
}

@end
