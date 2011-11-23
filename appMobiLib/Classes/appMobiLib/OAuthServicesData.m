//  OAuthServicesData.m

#import "AppMobiDelegate.h"
#import "OAuthServicesData.h"
#import "OAuthServicesParser.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation OAuthServicesData

@synthesize name2Service;
@synthesize secretkey;

- (NSString *)decryptServicesDotXml:(NSData *)servicesData
{
	if( servicesData == nil || [servicesData length] == 0 ) return @"";
	
	//setup crypto objects
	const void *vEncryptedText = [servicesData bytes];
	size_t encryptedTextBufferSize = [servicesData length];
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

- (void)parseServicesDotXml:(NSString*)decryptedServiceDotXml
{
	NSData *servicesData = [decryptedServiceDotXml dataUsingEncoding:NSASCIIStringEncoding];
	
	OAuthServicesParser *parser = [[OAuthServicesParser alloc] init];
	parser.dataBeingParsed = self;

	NSXMLParser *xmlParser = [NSXMLParser alloc];
	[xmlParser initWithData:servicesData];
	[xmlParser setDelegate:parser];
	[xmlParser parse];
	[parser release];	
}

- (id)init
{
	self = [super init];
	if( self != nil )
	{
		self.name2Service = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (void)initializeServices:(NSData *)servicesData
{
	NSString* decryptedServiceDotXml = [self decryptServicesDotXml:servicesData];
	[self parseServicesDotXml:decryptedServiceDotXml];
}

- (void)dealloc {
	[name2Service release];
	[super dealloc];
}

@end
