//  OAuthServicesParser.m

#import "OAuthServicesParser.h"

@implementation OAuthServicesParser

@synthesize dataBeingParsed;

/* 
<xml>
<service name="servicename1" appkey="appkey" secretkey="secretkey" requesttokenendpoint="requesttokenendpoint" authorizeendpoint="authorizeendpoint" accesstokenendpoint="accesstokenendpoint verb="POST"/>
<service name="servicename2" appkey="appkey" secretkey="secretkey" requesttokenendpoint="requesttokenendpoint" authorizeendpoint="authorizeendpoint" accesstokenendpoint="accesstokenendpoint" verb="POST"/>
</xml>
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"service"]) {
		OAuthService *service = [[OAuthService alloc] init];
		
		service.name = [[[attributeDict objectForKey:@"name"] copy] autorelease];
		service.appKey = [[[attributeDict objectForKey:@"appkey"] copy] autorelease];
		service.secret = [[[attributeDict objectForKey:@"secretkey"] copy] autorelease];
		service.requestTokenEndpoint = [[[attributeDict objectForKey:@"requesttokenendpoint"] copy] autorelease];
		service.authorizeEndpoint = [[[attributeDict objectForKey:@"authorizeendpoint"] copy] autorelease];
		service.accessTokenEndpoint = [[[attributeDict objectForKey:@"accesstokenendpoint"] copy] autorelease];
		service.verb = [[[attributeDict objectForKey:@"verb"] copy] autorelease];
		
		[dataBeingParsed.name2Service setValue:service forKey:service.name];
	}
}

@end