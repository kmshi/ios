//
// AppMobiFile.h
//

#import <UIKit/UIKit.h>
#import "FileUploadRequest.h"
#import "AppMobiCommand.h"

@interface AppMobiFile : AppMobiCommand <FileUploadRequestDelegate>
{
	NSString *fileUpload;
	NSString *updateCallback;
	FileUploadRequest *uploadRequest;
	BOOL bUploading;
	BOOL bShouldUpdate;
}

- (void) uploadToServer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) cancelUpload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// private methods
- (void) callJSwithError:(NSString*)error;

@end
