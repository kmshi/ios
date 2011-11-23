//
//  BookmarkConfigParser.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

@interface BookmarkConfigParser : NSObject <NSXMLParserDelegate> {
	BookmarkConfig *configBeingParsed;
}

@property (nonatomic, retain) BookmarkConfig *configBeingParsed;

@end
