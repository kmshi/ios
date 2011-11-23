//
// FileUploadRequest.m
// This file is added to the LFWebAPIKit

#import "FileUploadRequest.h"

NSString *const FileUploadTempFilenamePrefix = @"com.appMobi.upload";
NSString *const FileUploadRequestErrorDomain = @"com.appMobi.upload";

@interface FileUploadRequest (PrivateMethods)
- (void)cleanUpTempFile;
NS_INLINE NSString *GenerateUUIDString();
@end            

@implementation FileUploadRequest

@synthesize sessionInfo;
@synthesize delegate;

- (void)dealloc
{
    [HTTPRequest release];
    [sessionInfo release];
    
    [self cleanUpTempFile];
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        
        HTTPRequest = [[LFHTTPRequest alloc] init];
        [HTTPRequest setDelegate:self];
    }

    return self;
}


- (NSTimeInterval) requestTimeoutInterval
{
    return [HTTPRequest timeoutInterval];
}

- (void) setRequestTimeoutInterval:(NSTimeInterval) inTimeoutInterval
{
    [HTTPRequest setTimeoutInterval:inTimeoutInterval];
}

- (BOOL) isRunning
{
    return [HTTPRequest isRunning];
}

- (void) cancel
{
    [HTTPRequest cancelWithoutDelegateMessage];
    [self cleanUpTempFile];
}


- (BOOL) uploadFileStream:(NSInputStream *)inFileStream suggestedFilename:(NSString *)inFilename suggestedFoldername:(NSString *)inFoldername MIMEType:(NSString *)inType toEndPoint:(NSString *) uploadEndpoint
{
    if ([HTTPRequest isRunning]) {
        return NO;
    }

    NSString *separator = GenerateUUIDString();
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", separator];
    
    // build the multipart form
    NSMutableString *multipartBegin = [NSMutableString string];
    NSMutableString *multipartEnd = [NSMutableString string];

	[multipartBegin appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"Filename\"\r\n\r\n%@\r\n", separator, [inFilename length] ? inFilename : GenerateUUIDString()];
	if(inFoldername != nil)
		[multipartBegin appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"folder\"\r\n\r\n%@\r\n", separator, inFoldername];
	[multipartBegin appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", separator, [inFilename length] ? inFilename : GenerateUUIDString()];
    [multipartBegin appendFormat:@"Content-Type: %@\r\n\r\n", inType];
    [multipartEnd appendFormat:@"\r\n--%@--", separator];

    // create/clean a temp file
    [self cleanUpTempFile];
    uploadTempFilename = [[NSTemporaryDirectory() stringByAppendingFormat:@"%@.%@", FileUploadTempFilenamePrefix, GenerateUUIDString()] retain];
    
    // create the write stream
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:uploadTempFilename append:NO];
    [outputStream open];
    
    const char *UTF8String;
    size_t writeLength;
    UTF8String = [multipartBegin UTF8String];
    writeLength = strlen(UTF8String);
	
	size_t __unused actualWrittenLength;
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Must write multipartBegin");
	
    // open the input stream
    const size_t bufferSize = 65536;
    size_t readSize = 0;
    uint8_t *buffer = (uint8_t *)calloc(1, bufferSize);
    NSAssert(buffer, @"Must have enough memory for copy buffer");
	
    [inFileStream open];
    while ([inFileStream hasBytesAvailable]) {
        if (!(readSize = [inFileStream read:buffer maxLength:bufferSize])) {
            break;
        }
		size_t __unused actualWrittenLength;
		actualWrittenLength = [outputStream write:buffer maxLength:readSize];
        NSAssert (actualWrittenLength == readSize, @"Must completes the writing");
    }
    
    [inFileStream close];
    free(buffer);
    
    UTF8String = [multipartEnd UTF8String];
    writeLength = strlen(UTF8String);
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Must write multipartBegin");
    [outputStream close];
    
    NSError *error = nil;
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:uploadTempFilename error:&error];
    NSAssert(fileInfo && !error, @"Must have upload temp file");

    NSNumber *fileSizeNumber = [fileInfo objectForKey:NSFileSize];
    NSUInteger fileSize = 0;
	
    if ([fileSizeNumber respondsToSelector:@selector(integerValue)]) {
        fileSize = [fileSizeNumber integerValue];                    
    }
    else {
        fileSize = [fileSizeNumber intValue];                    
    }                
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:uploadTempFilename];
	
    [HTTPRequest setContentType:contentType];
    return [HTTPRequest performMethod:LFHTTPRequestPOSTMethod onURL:[NSURL URLWithString:uploadEndpoint] withInputStream:inputStream knownContentSize:fileSize];
}


#pragma mark LFHTTPRequest delegate methods

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
	// Currently does not process the html response, if needed can parse the XML or just pass [request receivedData] to the caller
	NSDictionary *rsp	= [NSDictionary dictionaryWithObject:@"Uploading done!" forKey:@"status"];

    [self cleanUpTempFile];
    if ([delegate respondsToSelector:@selector(FileUploadRequest:didCompleteWithResponse:)]) {
		[delegate FileUploadRequest:self didCompleteWithResponse:rsp];
    }    
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
    NSError *toDelegateError = nil;
    if ([error isEqualToString:LFHTTPRequestConnectionError]) {
		toDelegateError = [NSError errorWithDomain:FileUploadRequestErrorDomain code:FileUploadRequestConnectionError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Network connection error", NSLocalizedFailureReasonErrorKey, nil]];
    }
    else if ([error isEqualToString:LFHTTPRequestTimeoutError]) {
		toDelegateError = [NSError errorWithDomain:FileUploadRequestErrorDomain code:FileUploadRequestTimeoutError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Request timeout", NSLocalizedFailureReasonErrorKey, nil]];
    }
    else {
		toDelegateError = [NSError errorWithDomain:FileUploadRequestErrorDomain code:FileUploadRequestUnknownError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Unknown error", NSLocalizedFailureReasonErrorKey, nil]];
    }
    
    [self cleanUpTempFile];
    if ([delegate respondsToSelector:@selector(FileUploadRequest:didFailWithError:)]) {
        [delegate FileUploadRequest:self didFailWithError:toDelegateError];        
    }
}

- (void)httpRequest:(LFHTTPRequest *)request sentBytes:(NSUInteger)bytesSent total:(NSUInteger)total
{
    if (uploadTempFilename && [delegate respondsToSelector:@selector(FileUploadRequest:fileUploadSentBytes:totalBytes:)]) {
        [delegate FileUploadRequest:self fileUploadSentBytes:bytesSent totalBytes:total];
    }
}

@end

@implementation FileUploadRequest (PrivateMethods)

NS_INLINE NSString *GenerateUUIDString()
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
	
	return (NSString *)[NSMakeCollectable(uuidStr) autorelease];			    
}

- (void)cleanUpTempFile

{
    if (uploadTempFilename) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:uploadTempFilename]) {
			BOOL __unused removeResult = NO;
			NSError *error = nil;
			removeResult = [fileManager removeItemAtPath:uploadTempFilename error:&error];
			NSAssert(removeResult, @"Should be able to remove temp file");
        }
        
        [uploadTempFilename release];
        uploadTempFilename = nil;
    }
}

@end
