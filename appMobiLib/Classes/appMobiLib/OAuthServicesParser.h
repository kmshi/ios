//  OAuthServicesParser.h

#import "OAuthService.h"
#import "OAuthServicesData.h"

@interface OAuthServicesParser : NSObject<NSXMLParserDelegate> {
	OAuthServicesData *dataBeingParsed;
}

@property (nonatomic, retain) OAuthServicesData *dataBeingParsed;

@end
