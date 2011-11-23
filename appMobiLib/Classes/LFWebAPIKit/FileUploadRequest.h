//
// FileUploadRequest.h
// This file is added to the LFWebAPIKit

#import "LFWebAPIKit.h"

extern NSString *const FileUploadTempFilenamePrefix;
extern NSString *const FileUploadRequestErrorDomain;

enum {
    FileUploadRequestConnectionError = 0x7fff0001,
    FileUploadRequestTimeoutError = 0x7fff0002,    
	FileUploadRequestFaultyXMLResponseError = 0x7fff0003,
    FileUploadRequestUnknownError = 0x7fff0042
};

@class FileUploadRequest;

@protocol FileUploadRequestDelegate <NSObject>
@optional

- (void)FileUploadRequest:(FileUploadRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary;
- (void)FileUploadRequest:(FileUploadRequest *)inRequest didFailWithError:(NSError *)inError;
- (void)FileUploadRequest:(FileUploadRequest *)inRequest fileUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes;

@end

typedef id<FileUploadRequestDelegate> FileUploadRequestDelegateType;

@interface FileUploadRequest : NSObject
{
    LFHTTPRequest *HTTPRequest;
    
    FileUploadRequestDelegateType delegate;
    id sessionInfo;
    
    NSString *uploadTempFilename;
}

- (id) init;
- (BOOL) uploadFileStream:(NSInputStream *)inFileStream suggestedFilename:(NSString *)inFilename suggestedFoldername:(NSString *)inFoldername MIMEType:(NSString *)inType toEndPoint:(NSString *) uploadEndpoint;
- (BOOL) isRunning;
- (void) cancel;
- (NSTimeInterval) requestTimeoutInterval;
- (void) setRequestTimeoutInterval:(NSTimeInterval)inTimeInterval;

@property (nonatomic, assign) FileUploadRequestDelegateType delegate;
@property (nonatomic, retain) id sessionInfo;
@end
