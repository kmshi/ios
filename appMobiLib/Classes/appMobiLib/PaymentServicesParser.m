//  PaymentServicesParser.m

#import "PaymentServicesParser.h"

@implementation PaymentServicesParser

@synthesize dataBeingParsed;

/* 
<xml>
<service name="servicename1" id="key" />
<service name="servicename2" id="key" />
</xml>
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"service"]) {
		PaymentService *service = [[PaymentService alloc] init];
		
		service.name = [[[attributeDict objectForKey:@"name"] copy] autorelease];
		service.iden = [[[attributeDict objectForKey:@"id"] copy] autorelease];
		
		[dataBeingParsed.name2Payment setValue:service forKey:service.name];
	}
}

@end