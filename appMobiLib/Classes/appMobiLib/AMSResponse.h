//
//  AMSResponse.h
//  Slimfit
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface AMSPurchase: NSObject {
	NSString *app;
	NSString *rel;
	NSString *url;
	BOOL authorized;
	BOOL installed;
}

@property (nonatomic, retain) NSString *app;
@property (nonatomic, retain) NSString *rel;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) BOOL authorized;
@property (nonatomic, assign) BOOL installed;

@end

@interface AMSResponse: NSObject {
	NSString *name;
	NSString *result;
	NSString *message;
	NSString *email;
	NSString *user;
	NSMutableArray *notifications;
	NSMutableArray *purchases;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *purchases;

@end