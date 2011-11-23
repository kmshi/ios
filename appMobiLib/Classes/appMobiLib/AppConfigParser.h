//
//  AppConfigParser.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConfig.h"

@interface AppConfigParser : NSObject <NSXMLParserDelegate> {
	AppConfig *configBeingParsed;
}

@property (nonatomic, retain) AppConfig *configBeingParsed;

@end
