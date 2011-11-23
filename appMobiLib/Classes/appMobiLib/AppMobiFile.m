//
// AppMobiFile.m
//

#import "AppMobiFile.h" 
#import	"AppMobiWebView.h"
#import "AppConfig.h"
#import "AppMobiDelegate.h"

NSString *kUploadStep=@"UploadStep";

@implementation AppMobiFile

- (id)initWithWebView:(AppMobiWebView *)webview
{
    self = (AppMobiFile *) [super initWithWebView:webview];

	uploadRequest = [[FileUploadRequest alloc] init];
	uploadRequest.delegate = self;
	
	return self;
}

/*
 This is to upload a file to a server
 updateCallback is optional and is called periodically to show the status of update.
 localURL should contain 'localhost:xyz/path/.../filename'.  'filename' portion will be extracted and used to name the uploaded file.
 foldername could optionally be used to name the folder on the server.  It must be supplied, but could be null.
 mime is mime type of the file.  It must be supplied.  If null, default value will be used.
 uploadURL is the destination url
 */
- (void)uploadToServer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( bUploading == YES || uploadRequest.sessionInfo )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.file.upload.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	bUploading = YES;
	
	updateCallback = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:4]];	
	if( updateCallback == nil || [updateCallback length] == 0 ) return;
	else bShouldUpdate = YES;

	// file url, should be of format localhost:xxxx/path 
	NSString *filename = @"";
	NSString *url = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:0]];
	if( url == nil )
	{
		[self callJSwithError:@"Missing filename parameter."];
		return;
	}
		
	NSRange range = [url rangeOfString:@"localhost:58888/"];
	if(range.location == NSNotFound)
	{
		[self callJSwithError:@"Filename parameter is not fully qualified."];
		return;
	}
		
	NSString *uploadURL = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:1]];
	if(uploadURL == nil)
	{
		[self callJSwithError:@"Missing upload URL parameter."];
		return;
	}
	
	fileUpload = [[url copy] autorelease];
	filename = [url substringFromIndex:range.location + range.length];
	range = [filename rangeOfString:[NSString stringWithFormat:@"%@/%@/", webView.config.appName, webView.config.relName]];
	if( range.location != NSNotFound )
		   filename = [filename substringFromIndex:range.location + range.length];
	
	NSString *rootDirectory = [webView.config appDirectory];  // add appMobi's root folder
	NSString *path = [NSString stringWithFormat:@"%@/%@", rootDirectory, filename];  // make full local path
	
	// folder name
	NSString	*foldername = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:2]];

	// Mime Type
	NSString	*Mime = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:3]];
	if(Mime == nil) Mime = [[NSString alloc] initWithString:@"text/plain"]; // this should not happen since the js puts the default
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if(!fileExists) {
		[self callJSwithError:@"Cannot find the file for upload!"];
		return;
	}
    NSData *FileData = [[NSData alloc] initWithContentsOfFile:path];
	if (FileData == nil) {
		[self callJSwithError:@"Cannot open the file for upload!"];
		return;
	}
	
	NSString *file = filename;
	range = [filename rangeOfString:@"/" options:NSBackwardsSearch];
	if( range.location != NSNotFound )
	{
		file = [filename substringFromIndex:range.location+1];
	}
	
    uploadRequest.sessionInfo = kUploadStep;
	[uploadRequest uploadFileStream:[NSInputStream inputStreamWithData:FileData] suggestedFilename:file suggestedFoldername:foldername MIMEType:Mime toEndPoint:uploadURL];
}

- (void)cancelUpload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	uploadRequest.sessionInfo = nil;
	bUploading = NO;
	bShouldUpdate = NO;
	
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.file.upload.cancel',true,true);e.success=true;e.localURL='%@';document.dispatchEvent(e);", fileUpload];
	AMLog(@"%@",js);
	[webView injectJS:js];
}

#pragma mark FileUploadRequest delegate methods

- (void)FileUploadRequest:(FileUploadRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	uploadRequest.sessionInfo = nil;
	bUploading = NO;
	bShouldUpdate = NO;
	
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.file.upload',true,true);e.success=true;e.localURL='%@';document.dispatchEvent(e);", fileUpload];
	AMLog(@"%@",js);
	[webView injectJS:js];
}

- (void)FileUploadRequest:(FileUploadRequest *)inRequest didFailWithError:(NSError *)inError
{
	uploadRequest.sessionInfo = nil;
	bUploading = NO;
	bShouldUpdate = NO;

	NSString *error = [inError description];
	if(error)
		[self callJSwithError:error];
}

- (void)FileUploadRequest:(FileUploadRequest *)inRequest fileUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
	if( bShouldUpdate == YES )
	{
		NSString *js = [NSString stringWithFormat:@"%@(%lu, %lu);", updateCallback, inSentBytes, inTotalBytes];
		AMLog(@"%@",js);
		[webView injectJS:js];
	}
}

#pragma mark private methods

- (void)dealloc
{
	[uploadRequest release];
	[fileUpload release];
	[updateCallback release];
    [super dealloc];
}

- (void)callJSwithError:(NSString*)error
{
	NSString * tempstring= [error stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.file.upload',true,true);e.success=false;e.message='%@';document.dispatchEvent(e);", tempstring];
	AMLog(@"%@",js);
	[webView injectJS:js];
	bUploading = NO;
	return;
}

@end
