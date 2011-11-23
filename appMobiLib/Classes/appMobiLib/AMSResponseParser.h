//
//  AMSResponseParser.h
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AMSResponse.h"
#import "AMSNotification.h"

@interface AMSResponseParser : NSObject<NSXMLParserDelegate> {
	AMSResponse *responseBeingParsed;
	NSMutableString *currentProperty;
	NSSet *subNodeNames;
}

@property (nonatomic, retain) AMSResponse *responseBeingParsed;
@property (nonatomic, retain) NSMutableString *currentProperty;
@property (nonatomic, retain) NSSet *subNodeNames;

- (void)parseXMLData:(NSData *)data;

@end
