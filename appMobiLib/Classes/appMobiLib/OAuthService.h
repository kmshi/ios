//  OAuthService.h

@interface OAuthService: NSObject {
	NSString *name;
	NSString *appKey;
	NSString *secret;
	NSString *requestTokenEndpoint;
	NSString *authorizeEndpoint;
	NSString *accessTokenEndpoint;
	NSString *verb;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *requestTokenEndpoint;
@property (nonatomic, retain) NSString *authorizeEndpoint;
@property (nonatomic, retain) NSString *accessTokenEndpoint;
@property (nonatomic, retain) NSString *verb;

@end