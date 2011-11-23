//  PaymentServicesData.m

#import "AppMobiDelegate.h"
#import "PaymentServicesData.h"
#import "PaymentServicesParser.h"
#import <CommonCrypto/CommonDigest.h>;
#import <CommonCrypto/CommonCryptor.h>;

@implementation PaymentServicesData

@synthesize name2Payment;
@synthesize secretkey;

- (NSString *)decryptServicesDotXml:(NSData *)paymentsData
{
	if( paymentsData == nil || [paymentsData length] == 0 ) return @"";
	
	//setup crypto objects
	const void *vEncryptedText = [paymentsData bytes];
	size_t encryptedTextBufferSize = [paymentsData length];
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	bufferPtrSize = (encryptedTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
	//md5 key data
	const char *key = [secretkey cStringUsingEncoding:NSASCIIStringEncoding];

	//decrypt data and return string 
	ccStatus = CCCrypt(kCCDecrypt,
		kCCAlgorithm3DES,
		kCCOptionECBMode,
		key,
		kCCKeySize3DES,
		NULL,
		vEncryptedText,
		encryptedTextBufferSize,
		(void *)bufferPtr,
		bufferPtrSize,
		&movedBytes);
	
	if (ccStatus == kCCParamError) return @"PARAM ERROR";
	else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
	else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
	else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
	else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
	else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
	
	NSString *result = [[[NSString alloc] initWithData: [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding] autorelease];
	return result;
}

- (void)parsePaymentsDotXml:(NSString*)decryptedPaymentsDotXml
{
	NSData *paymentsData = [decryptedPaymentsDotXml dataUsingEncoding:NSASCIIStringEncoding];
	
	PaymentServicesParser *parser = [[PaymentServicesParser alloc] init];
	parser.dataBeingParsed = self;

	NSXMLParser *xmlParser = [NSXMLParser alloc];
	[xmlParser initWithData:paymentsData];
	[xmlParser setDelegate:parser];
	[xmlParser parse];
	[parser release];	
}

- (id)init
{
	self = [super init];
	if( self != nil )
	{
		self.name2Payment = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (void)initializePayments:(NSData *)paymentsData
{
	NSString* decryptedPaymentsDotXml = [self decryptServicesDotXml:paymentsData];
	[self parsePaymentsDotXml:decryptedPaymentsDotXml];
}

- (void)dealloc {
	[name2Payment release];
	[super dealloc];
}

@end
