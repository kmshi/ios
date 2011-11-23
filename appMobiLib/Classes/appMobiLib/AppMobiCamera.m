//
//  AppMobiCalendar.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiCamera.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"
#import "AppConfig.h"
#import "AppMobiWebView.h"
#import <EventKit/EventKit.h>

@implementation AppMobiCamera

@synthesize imagePickerController;
@synthesize	pictureList;

// dev notes from JS
/*
 camera.takePicture
 
 quality affects jpeg compression, value should be between 1-100 - default=70.  
 savetoLib='no' indicates do not save to device's photo library (Camera Roll) - default = yes
 picType can be 'jpg' or 'png' - default = 'jpg'
 
 at completion fires appMobi.camera.picture.add event.
 event.success = true or false
 event.url, url of the new 'cached' file on system
 event.name, filename
 at completion adds the filename to AppMobi.picturelist array
 camera.importPicture
 
 at completion fires appMobi.camera.picture.add event.
 event.success = true or false
 event.url, url of the new 'cached' file on system
 event.name, filename
 at completion adds the filename to AppMobi.picturelist array

 camera.deletePicture
 
 picURL is the pathname to the local picture file to be deleted, it could be obtained
 by calling getPictureURL(pictures[index]).  
 
 at completion fires appMobi.camera.picture.remove event.
 event.success = true or false
 event.url, url of removed 'cached' file on system
 event.name, filename of removed file
 at completion removes the filename from AppMobi.picturelist array

 camera.clearPictures
 
 at completion fires appMobi.camera.picture.clear event.
 event.success = true or false
 at completion clears the AppMobi.picturelist array
//*/

-(id) initWithWebView:(AppMobiWebView *)webview
{
	busyGettingPicture = FALSE;
    self = (AppMobiCamera *) [super initWithWebView:webview];
	
	// get pictures directory, create if does not exist
	picturesDirectory = [[webView.config.appDirectory stringByAppendingPathComponent:@"_pictures"] retain];
	if(![[NSFileManager defaultManager] fileExistsAtPath:picturesDirectory isDirectory:nil])
		[[NSFileManager defaultManager] createDirectoryAtPath:picturesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		
	return self;
}

// This gets called at startup time, so init stuff happens in here
- (NSDictionary*) makePictureList
{
	if( webView.config == nil && picturesDirectory == nil ) return [NSMutableDictionary dictionaryWithCapacity:1];

	NSError *err = nil;
	NSArray *pictureFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:picturesDirectory error:&err];
	AMLog(@"****picture files****: %@",[pictureFiles description]);
	
	if(pictureList==nil) {
		pictureList = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
		
		NSString *pictureJar = [NSString stringWithFormat:@"%@.picture", webView.config.appName];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];		
		if([defaults objectForKey:pictureJar]!=nil) {
			[pictureList setDictionary:(NSDictionary *)[defaults objectForKey:pictureJar]];
		}
	}
	[self retain];
	return pictureList;
}

- (void) takePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *quality = nil;
	
	if(busyGettingPicture) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	busyGettingPicture = TRUE;

	quality = (NSString *)[arguments objectAtIndex:0];
	if(quality == nil) quality = @"70";  // default value, This should not happen since js puts the default
	picQuality = [quality intValue];
	if (picQuality<1 || picQuality >100) { //This should not happen with the check done in js
		picQuality = 70;
	}
	picQuality = picQuality/100;
	
	saveToLibrary = YES;
	if([arguments count]>1)
		saveToLibrary = [(NSString *)[arguments objectAtIndex:1] boolValue];

	if([arguments count]>2)
		picType = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:2]];
	if(picType == nil)
		picType = @"jpg";
	if([picType caseInsensitiveCompare:@"png"])
		picType = @"jpg";
	
    if(![self showImagePicker:UIImagePickerControllerSourceTypeCamera]) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.add',true,true);e.success=false;e.message='Camera not supported';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		busyGettingPicture = NO;
	}
}

- (void) importPicture:(NSMutableArray*) arguments withDict:(NSMutableDictionary*)options
{
	if(busyGettingPicture) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
	}
	else {
		busyGettingPicture = TRUE;
		saveToLibrary = FALSE;
		picType = @"jpg";
		if(![self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary]) { //:option. can add option to use PhotoLibrary or just CameraRoll (SavedPhotoAlbums)
			NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.add',true,true);e.success=false;e.message='Library not supported';document.dispatchEvent(e);"];
			AMLog(@"%@",js);
			[webView injectJS:js];
		}
	}
}

- (void) deletePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	BOOL removed = FALSE;
	NSString *js, *filename=@"none", *filePath=@"none";
	
	NSString *url = [[NSString alloc] initWithString:(NSString *)[arguments objectAtIndex:0]];	
	if( url != nil && [url length] != 0 ) {
		int loc = [url rangeOfString:@"/" options:NSBackwardsSearch].location;
		if(loc != NSNotFound) {
			filename = [url substringFromIndex:loc+1];
		}
		else
		{
			filename = url;
		}

		filePath = [NSString stringWithFormat:@"%@/%@", picturesDirectory, filename];
		if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] )
			removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}

	if(removed) {
		//update the dictionary
		[pictureList removeObjectForKey:filename];
		NSString *pictureJar = [NSString stringWithFormat:@"%@.picture", webView.config.appName];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:pictureList forKey:pictureJar];
		[defaults synchronize];
		
		js = [NSString stringWithFormat:@"var i = 0; while (i < AppMobi.picturelist.length) { if (AppMobi.picturelist[i] == '%@') { AppMobi.picturelist.splice(i, 1); } else { i++; }};var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.remove',true,true);e.success=true;e.filename='%@';document.dispatchEvent(e);", filename, filename];
		
	} else 
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.remove',true,true);e.success=false;e.filename='%@';document.dispatchEvent(e);", filename];

	//update js object and fire an event
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void) clearPictures:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	[[NSFileManager defaultManager] removeItemAtPath:picturesDirectory error:nil];
	//empty the dictionary
	pictureList = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	//create an empty directory
	[[NSFileManager defaultManager] createDirectoryAtPath:picturesDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	//
	NSString *pictureJar = [NSString stringWithFormat:@"%@.picture", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:pictureList forKey:pictureJar];
	[defaults synchronize];
	
	//update js object and fire an event
	NSString *js = @"AppMobi.picturelist = new Array();var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.clear',true,true);e.success=true;document.dispatchEvent(e);";
	AMLog(@"%@", js);
	[webView injectJS:js];
}


- (void) dealloc
{
    [imagePickerController release];
	[picType release];
	[pictureList release];
	[picturesDirectory release];
	[super dealloc];
}

#pragma mark -

- (BOOL)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
	if( self.imagePickerController == nil )
	{
	   self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
	   // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
	   self.imagePickerController.delegate = self;
	}	   
	
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
		self.imagePickerController.sourceType = sourceType;
		if (sourceType == UIImagePickerControllerSourceTypeCamera)
			self.imagePickerController.showsCameraControls = YES;
		
		if( [AppMobiDelegate isIPad] == YES )
		{
			UIView *view = [AppMobiViewController masterViewController].view;			
			popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
			popoverController.delegate = self;
			[popoverController presentPopoverFromRect:CGRectMake(0, 0, 320, 480) inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
		{
			[[AppMobiViewController masterViewController] presentModalViewController:self.imagePickerController animated:YES];
		}
		return TRUE;
    }
	return FALSE;
}

- (void)didTakePicture:(UIImage *) picture
{
    NSString *js;
	NSData* data;
	NSError *error;
	
	if([picType caseInsensitiveCompare:@"png"])
		data = UIImageJPEGRepresentation(picture, picQuality);
	else
		data = UIImagePNGRepresentation(picture);

	// find an unsued filename
	NSString* filePath;
	int i=0;
	do {
		filePath = [NSString stringWithFormat:@"%@/picture_%03d.%@", picturesDirectory, ++i, picType];
	} while([[NSFileManager defaultManager] fileExistsAtPath: filePath]);

	NSString *filename = [filePath substringFromIndex:[filePath rangeOfString:@"/" options:NSBackwardsSearch].location+1];

	// save into pic library
	if(saveToLibrary)
		UIImageWriteToSavedPhotosAlbum (picture, nil, nil , nil);
		
	// save the file in appMobiCache/_pictures directory
	BOOL success = [data writeToFile: filePath options: NSAtomicWrite error: &error];
	
	if(success) {
		if([pictureList objectForKey:filename]==nil) {
			[pictureList setObject:[NSDictionary dictionaryWithObjectsAndKeys:filename, @"file", nil] forKey:filename];
			NSString *pictureJar = [NSString stringWithFormat:@"%@.picture", webView.config.appName];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:pictureList forKey:pictureJar];
			[defaults synchronize];
			
			//update js object and fire an event
			js = [NSString stringWithFormat:@"AppMobi.picturelist.push('%@');var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.add',true,true);e.success=true;e.filename='%@';document.dispatchEvent(e);", filename, filename];
		} else {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.add',true,true);e.success=true;e.filename='%@';document.dispatchEvent(e);", filename];
		}
	} else
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.add',true,true);e.success=false;e.filename='%@';document.dispatchEvent(e);", filename];
	
	AMLog(@"%@",js);
	[webView injectJS:js];
}

- (void)didFinishWithCamera
{
	if( popoverController != nil )
	{
		[popoverController dismissPopoverAnimated:YES];
		[popoverController release];
		popoverController = nil;
	}
	else
		[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:NO];
	busyGettingPicture = FALSE;
	
	if( cancelled == YES )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.camera.picture.cancel',true,true);e.success=false;document.dispatchEvent(e);"];
		//update js object and fire an event
		AMLog(@"%@", js);
		[webView injectJS:js];
	}
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
	cancelled = NO;
    [self didTakePicture:image];
	[self didFinishWithCamera];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	cancelled = YES;
    [self didFinishWithCamera];    // tell our delegate we are finished with the picker
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	cancelled = YES;
    [self didFinishWithCamera];    // tell our delegate we are finished with the picker
}

@end
