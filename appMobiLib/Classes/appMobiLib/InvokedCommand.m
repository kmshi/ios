//
//  InvokedUrlCommand.m
//  AppMobi
//
//  Created by Shazron Abdullah on 13/08/09.
//  Copyright 2009 Nitobi Inc. All rights reserved.
//

#import "InvokedCommand.h"
#import "JSON.h"

@implementation InvokedCommand

@synthesize arguments;
@synthesize options;
@synthesize command;
@synthesize className;
@synthesize methodName;

+ (InvokedCommand*) newFromUrl:(NSURL*)url
{
    /*
	 * Get Command and Options From URL
	 * We are looking for URLS that match yourscheme://<Class>.<command>/[<arguments>][?<dictionary>]
	 * We have to strip off the leading slash for the options.
	 *
	 * Note: We have to go through the following contortions because NSURL "helpfully" unescapes
	 * certain characters, such as "/" from their hex encoding for us. This normally wouldn't
	 * be a problem, unless your argument has a "/" in it, such as a file path.
	 */
	InvokedCommand* iuc = [[InvokedCommand alloc] init];
	
    iuc.command = [url host];
	
	NSString * fullUrl = [url description];
	int prefixLength = [[url scheme] length] + [@"://" length] + [iuc.command length] + 1; // "yourscheme://" plus command plus the leading "/" (magic number 1)
	int qsLength = [[url query] length];
	int pathLength = [fullUrl length] - prefixLength;

	// remove query string length
    if (qsLength > 0)
		pathLength = pathLength - qsLength - 1; // 1 is the "?" char
	// remove leading forward slash length
	else if ([fullUrl hasSuffix:@"/"] && pathLength > 0)
		pathLength -= 1; // 1 is the "/" char 
	
    NSString *path = [fullUrl substringWithRange:NSMakeRange(prefixLength, pathLength)];
	
	// Array of arguments
	NSMutableArray* arguments = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
	int i, arguments_count = [arguments count];
	for (i = 0; i < arguments_count; i++) {
		[arguments replaceObjectAtIndex:i withObject:[(NSString *)[arguments objectAtIndex:i]
													  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	iuc.arguments = arguments;
    
	// Dictionary of options
	NSString* objectString = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	iuc.options = (NSMutableDictionary*)[objectString JSONValue];
	
	NSMutableArray* components = [NSMutableArray arrayWithArray:[iuc.command componentsSeparatedByString:@"."]];
	if (components.count >= 2) {
		iuc.methodName = [components lastObject];
		[components removeLastObject];
		iuc.className = [components componentsJoinedByString:@"."];
	}		
	
	return iuc;
}

- (void) dealloc
{
	[arguments release];
	[options release];
	[command release];
	[className release];
	[methodName release];
	
	[super dealloc];
}

@end
