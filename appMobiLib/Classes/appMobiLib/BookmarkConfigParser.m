//
//  BookmarkConfigParser.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookmarkConfigParser.h"
#import "Bookmark.h"

@implementation BookmarkConfigParser

@synthesize configBeingParsed;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"bookmarks"]) {
		//get the revision
		
		configBeingParsed.sequence = [[attributeDict objectForKey:@"sequence"] intValue];
	}
	if([elementName isEqualToString:@"bookmark"]) {
		Bookmark *bookmark = [[Bookmark alloc] init];
		bookmark.name = [[[attributeDict objectForKey:@"name"] copy] autorelease];
		bookmark.imageurl = [[[attributeDict objectForKey:@"image"] copy] autorelease];
		bookmark.url = [[[attributeDict objectForKey:@"url"] copy] autorelease];
		bookmark.appname = [[[attributeDict objectForKey:@"appname"] copy] autorelease];
		bookmark.relname = [[[attributeDict objectForKey:@"relname"] copy] autorelease];
		bookmark.appconfigurl = [[[attributeDict objectForKey:@"appconfig"] copy] autorelease];
		bookmark.webroot = [[[attributeDict objectForKey:@"webroot"] copy] autorelease];
		bookmark.buypage = [[[attributeDict objectForKey:@"buypage"] copy] autorelease];
		bookmark.bookpage = [[[attributeDict objectForKey:@"bookmarkpage"] copy] autorelease];
		bookmark.paypage = [[[attributeDict objectForKey:@"paypage"] copy] autorelease];
		
		[configBeingParsed.bookmarks addObject:bookmark];
	}
}

@end
