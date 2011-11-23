//
//  AppMobiCamera.h
//  appMobiLib
//
//  Copyright 2011 appMobi. All rights reserved.
//

#import "AppMobiCommand.h"

@interface AppMobiCamera : AppMobiCommand <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    UIImagePickerController *imagePickerController;
	UIPopoverController *popoverController;
	
	float	picQuality;
	NSString *picType;
	BOOL    cancelled;
	bool	saveToLibrary;
	bool	busyGettingPicture;  // flag to prevent being called while taking or importing a picture
	NSMutableDictionary* pictureList;
	NSString	*picturesDirectory;
}

@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSMutableDictionary* pictureList;

- (void)takePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)importPicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)deletePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)clearPictures:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (NSDictionary*) makePictureList;
- (BOOL)showImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end
