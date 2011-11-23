//  PaymentServicesParser.h

#import "PaymentService.h"
#import "PaymentServicesData.h"

@interface PaymentServicesParser : NSObject<NSXMLParserDelegate> {
	PaymentServicesData *dataBeingParsed;
}

@property (nonatomic, retain) PaymentServicesData *dataBeingParsed;

@end
