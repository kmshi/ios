//
//  AppMobiResponse.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define APPMOBI_BUSY = 101;
#define APPMOBI_CANCELLED = 102;
#define APPMOBI_UNAUTHORIZED = 103;
#define APPMOBI_NORMAL = 104;

@interface AppMobiResponse: NSObject
{
	NSString *event;
	NSString *message;
	NSString *result;
	NSString *identifier;
	
	int state; // BUSY, CANCELLED, UNAUTHORIZED, NORMAL
	
	BOOL success;
}

@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, readwrite) int state;
@property (nonatomic, readwrite) BOOL success;

@end