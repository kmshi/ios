//
//  AppMobiAnalytics.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"


@interface PageEvent : NSObject<NSCoding>
{
	NSString *page;
	NSString *url;
	NSDate *date;
}

@property (nonatomic, retain) NSString *page;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *date;

@end


@interface AppMobiAnalytics : AppMobiCommand
{
	NSMutableArray *arEvents;
	NSLock *lkEvents;
	NSString *strDeviceID;
}

@property (nonatomic, readonly) NSString *strDeviceID;

- (void)logPageEvent:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
