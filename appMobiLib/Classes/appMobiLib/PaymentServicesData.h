//  PaymentServicesData.h

@interface PaymentServicesData: NSObject {
	NSMutableDictionary *name2Payment;
	NSString *secretkey;
}

- (void)initializePayments:(NSData *)paymentsData;

@property (nonatomic, retain) NSDictionary *name2Payment;
@property (nonatomic, retain) NSString *secretkey;

@end