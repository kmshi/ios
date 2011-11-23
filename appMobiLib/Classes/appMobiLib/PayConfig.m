//
//  Config.m
//  appMobiLib
//
//  Created by Tony Homer on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PayConfig.h"

@implementation PayConfig

@synthesize keys, pref, data, isVerified;

- (void) dealloc {
	[keys release];
	[pref release];
	[data release];
	[super dealloc];
}

@end
