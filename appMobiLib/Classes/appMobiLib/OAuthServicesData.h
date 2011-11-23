//  OAuthServicesData.h

@interface OAuthServicesData: NSObject {
	NSMutableDictionary *name2Service;
	NSString *secretkey;
}

- (void)initializeServices:(NSData *)servicesData;

@property (nonatomic, retain) NSDictionary *name2Service;
@property (nonatomic, retain) NSString *secretkey;

@end