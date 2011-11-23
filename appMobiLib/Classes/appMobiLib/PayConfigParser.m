//
//  PayConfigParser.m
//  appMobiLib
//
//  Created by Tony Homer on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PayConfigParser.h"


@implementation PayConfigParser

@synthesize configBeingParsed;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"getapppaymentinfo"]) {
		//get the revision
		configBeingParsed.keys = [attributeDict objectForKey:@"key"];
		configBeingParsed.pref = [attributeDict objectForKey:@"preferredpaymentid"];
		configBeingParsed.data = [attributeDict objectForKey:@"extendedinfo"];
		configBeingParsed.isVerified = [[attributeDict objectForKey:@"isverified"] boolValue];
		
		//NSLog(@"Reading attributes :%@,%@,%@", configBeingParsed.keys, configBeingParsed.pref, configBeingParsed.data);
	}
	//NSLog(@"Processing Element: %@", elementName);
}

@end
