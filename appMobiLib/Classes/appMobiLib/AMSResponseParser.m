//
//  AMSResponseParser.m
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AMSResponseParser.h"
#import "AppMobiDelegate.h"

@implementation AMSResponseParser

@synthesize responseBeingParsed, currentProperty, subNodeNames;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.currentProperty) {
		[currentProperty appendString:string];
	}
}

- (void)parseXMLData:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	if( parser == nil ) return;
	
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    [parser parse];
    [parser release];
}

//{"aps":{"alert":"test message","badge":"3","sound":"default"},"id":"11","data":"[[twitter.app]]test data"}
/*
 <function name="ampush.getmessagesforuser" return="ok" msg="" >
 <msgcount>1</msgcount>
 <message number="1" id="1" message="test message" userdata="[[twitter.app]]test data" />
 </function> 
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"function"]) {
		responseBeingParsed = [[AMSResponse alloc] init];
		responseBeingParsed.notifications = [[[NSMutableArray alloc] init] autorelease];
		responseBeingParsed.name = [[[attributeDict objectForKey:@"name"] copy] autorelease];
		responseBeingParsed.result = [[[attributeDict objectForKey:@"return"] copy] autorelease];
		responseBeingParsed.message = [[[attributeDict objectForKey:@"msg"] copy] autorelease];
		responseBeingParsed.user = [[[attributeDict objectForKey:@"username"] copy] autorelease];
		responseBeingParsed.email = [[[attributeDict objectForKey:@"email"] copy] autorelease];
		
		AMLog(@"Reading attributes :%@,%@,%@,%@", responseBeingParsed.name, responseBeingParsed.result, responseBeingParsed.message, responseBeingParsed.email);
	} else if([elementName isEqualToString:@"message"]) {
		AMSNotification *notification = [[AMSNotification alloc] init];
		[responseBeingParsed.notifications addObject:notification];
		
		notification.ident = [[attributeDict objectForKey:@"id"] intValue];
		notification.userkey = [[[attributeDict objectForKey:@"userkey"] copy] autorelease];
		notification.message = [[[attributeDict objectForKey:@"message"] copy] autorelease];
		notification.target = [[[attributeDict objectForKey:@"usertarget"] copy] autorelease];
		notification.url = [[[attributeDict objectForKey:@"userurl"] copy] autorelease];
		notification.data = [[[attributeDict objectForKey:@"userdata"] copy] autorelease];
		notification.richhtml = [[[attributeDict objectForKey:@"richhtml"] copy] autorelease];
		notification.richurl = [[[attributeDict objectForKey:@"richurl"] copy] autorelease];
		notification.hidden = [[attributeDict objectForKey:@"hidden"] boolValue];
		
		notification.isrich = ( [notification.richurl length] > 0 || [notification.richhtml length] > 0 );
		
		AMLog(@"Reading attributes :%d,%@,%@", notification.ident, notification.message, notification.data);
	}
	else if([elementName isEqualToString:@"GetAuthorizedItems"]) {
		responseBeingParsed = [[AMSResponse alloc] init];
		responseBeingParsed.purchases = [[[NSMutableArray alloc] init] autorelease];
	} else if([elementName isEqualToString:@"purchase"]) {
		AMSPurchase *purchase = [[AMSPurchase alloc] init];
		[responseBeingParsed.purchases addObject:purchase];
		
		purchase.app = [[[attributeDict objectForKey:@"app"] copy] autorelease];
		purchase.rel = [[[attributeDict objectForKey:@"rel"] copy] autorelease];
		purchase.url = [[[attributeDict objectForKey:@"url"] copy] autorelease];
		purchase.authorized = [[attributeDict objectForKey:@"authorized"] intValue];
		
		AMLog(@"Reading attributes :%@,%@,%@,%d", purchase.app, purchase.rel, purchase.url, purchase.authorized);
	}
	//AMLog(@"Processing Element: %@", elementName);
}

@end