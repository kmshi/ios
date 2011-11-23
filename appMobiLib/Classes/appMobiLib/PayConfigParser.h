//
//  PayConfigParser.h
//  appMobiLib
//
//  Created by Tony Homer on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayConfig.h"

@interface PayConfigParser : NSObject <NSXMLParserDelegate> {
	PayConfig *configBeingParsed;
}

@property (nonatomic, retain) PayConfig *configBeingParsed;

@end
