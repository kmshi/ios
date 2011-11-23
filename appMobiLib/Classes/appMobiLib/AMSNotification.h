//
//  AMSNotification.h
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface AMSNotification: NSObject {
	int ident;
	NSString *userkey;
	NSString *data;
	NSString *message;
	NSString *url;
	NSString *target;
	NSString *richurl;
	NSString *richhtml;
	BOOL isrich;
	BOOL hidden;
}

@property (nonatomic) int ident;
@property (nonatomic, retain) NSString *userkey;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *target;
@property (nonatomic, retain) NSString *richurl;
@property (nonatomic, retain) NSString *richhtml;
@property (nonatomic) BOOL isrich;
@property (nonatomic) BOOL hidden;

@end