//
//  AppMobiAdvertising.m
//  appLab
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiAdvertising.h"
#import "AppMobiDelegate.h"
#import "AppConfig.h"
#import "AppConfigParser.h"
#import "ZipArchive.h"
#import "AppMobiWebView.h"
#import "AppMobiViewController.h"

@implementation AppMobiAdvertising

NSString *cachedAdDirectory = nil;
BOOL showFullscreen = NO;

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiAdvertising *) [super initWithWebView:webview];
	cachedAdDirectory = [[webView.config.appDirectory stringByAppendingPathComponent:@"_adcache"] retain];
	return self;
}

- (void)showFullscreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *adname = (NSString *)[arguments objectAtIndex:0];

	if( adname == nil || [adname length] == 0 ) return;
	
	NSString* currentAdBaseDir = [[AppMobiDelegate baseDirectory] stringByAppendingPathComponent:adname];//the top-level directory for this ad
	NSString* currentAdExtractDir = [currentAdBaseDir stringByAppendingPathComponent:@"AppMobiCache"];//the directory ad content gets extracted into
	NSString* currentAdFullscreenDir = [currentAdExtractDir stringByAppendingPathComponent:@"fullscreen"];//the directory for fullscreen part of ad
	NSString* url = [currentAdFullscreenDir stringByAppendingPathComponent:@"index.html"];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:url];
	if( success == YES )
	{
		AppMobiViewController *vc = [AppMobiViewController masterViewController];
		[vc showAdFull:url];
		showFullscreen = YES;
	}
	
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.advertising.fullscreen.show',true,true);e.success=%@;document.dispatchEvent(e);", success?@"true":@"false"];
	[webView injectJS:js];
}

- (void)hideFullscreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( showFullscreen == NO ) return;
	
	AppMobiViewController *vc = [AppMobiViewController masterViewController];
	[vc hideAdFull:nil];

	showFullscreen = NO;
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.advertising.fullscreen.hide',true,true);document.dispatchEvent(e);"];
	[webView injectJS:js];
}

-(void) checkForNestedDirectory:(NSString*)adDir {
	NSString* currentAdExtractDir = [adDir stringByAppendingPathComponent:@"AppMobiCache"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[currentAdExtractDir stringByAppendingPathComponent:@"index.html"]] == NO) {
		/*
		 //check if bundle contents are inside a top-level directory -- if so, move top-level directory contents into root
		 */
		//get list of contents in appMobiCache
		NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentAdExtractDir error:nil];
		NSArray *ignoreList = [NSArray arrayWithObjects:@"_mediacache", @"_appMobi", @"__MACOSX", nil];
		
		int dirCount = 0;
		NSString *path;
		for(int i=0;i<[array count];i++) {
			if(![ignoreList containsObject:[array objectAtIndex:i]]) {
				path = [currentAdExtractDir stringByAppendingPathComponent:[array objectAtIndex:i]];
				dirCount++;
			}
		}
		BOOL isDir;
		//is it a directory with an index.html inside?
		if(dirCount==1 && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir && [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"index.html"]]) {
			/*
			 //move to a temp folder, delete top-level directory, then move contents into root
			 */
			//create temp folder
			NSString *tempPath = [adDir stringByAppendingPathComponent:@"temp"];
			[[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:NO attributes:nil error:nil];
			//get list of files to move
			array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
			//move files to temp folder
			for(int i=0;i<[array count];i++) {
				NSString *file = [array objectAtIndex:i];
				[[NSFileManager defaultManager] moveItemAtPath:[path stringByAppendingPathComponent:file] toPath:[tempPath stringByAppendingPathComponent:file] error:nil];
			}
			//delete top-level directory
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			//move content into root
			array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
			//move files to temp folder
			for(int i=0;i<[array count];i++) {
				NSString *file = [array objectAtIndex:i];
				[[NSFileManager defaultManager] copyItemAtPath:[tempPath stringByAppendingPathComponent:file] toPath:[currentAdExtractDir stringByAppendingPathComponent:file] error:nil];
			}
			//delete temporary directory
			[[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
		} else {
			AMLog(@"missing index for ad");
		}
	}	
}

-(BOOL) getAndExtractAdBundle:(AppConfig*)config adDir:(NSString*)adDir oldConfigFile:(NSString*)oldConfigFile newConfigFile:(NSString*)newConfigFile {
	BOOL success = NO;
	
	//get bundle url
	//append deviceid & platform
	NSString* bundleURL = config.bundleURL;//[NSString stringWithFormat:@"%@%c%@%@", config.bundleURL, ([config.bundleURL rangeOfString:@"?"].location!=NSNotFound)?'&':'?', @"platform=ios&deviceid=", [[UIDevice currentDevice] uniqueIdentifier]];
	//download bundle
	NSMutableData *receivedData = [[NSMutableData alloc] initWithLength:0];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:bundleURL]];
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	[receivedData appendData:result];
	NSString* bundlePath = [adDir stringByAppendingPathComponent:@"bundle.zip"];
	[[NSFileManager defaultManager] createFileAtPath:bundlePath contents:receivedData attributes:nil];
	//delete current ad-specific cache
	NSString* currentAdExtractDir = [adDir stringByAppendingPathComponent:@"AppMobiCache"];
	[[NSFileManager defaultManager] removeItemAtPath:currentAdExtractDir error:nil];
	//extract bundle into ad-specific cache
	ZipArchive *za = [[ZipArchive alloc] init];
	if ([za UnzipOpenFile: bundlePath]) {
		BOOL ret = [za UnzipFileTo: currentAdExtractDir overWrite: YES];
		if (NO == ret){} [za UnzipCloseFile];
	}
	[za release];
	//check if there was a nested subdirectory in the bundle
	[self checkForNestedDirectory:adDir];
	//update config file
	[[NSFileManager defaultManager] removeItemAtPath:oldConfigFile error:nil];
	[[NSFileManager defaultManager] moveItemAtPath:newConfigFile toPath:oldConfigFile error:nil];
	//cleanup the ad archive
	[[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
	//if everything worked, set success to true
	success = YES;
	
	return success;
}

- (BOOL)downloadConfig:(NSString*)configURLString configPath:(NSString*)configPath {	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	configURLString = [configURLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSURL *configURL = [NSURL URLWithString:configURLString];
	//write config to disk
	NSData *configData = [NSData dataWithContentsOfURL:configURL];
	BOOL success = [[NSFileManager defaultManager] createFileAtPath: configPath contents:configData attributes:nil];
	[pool release];
	return success;
}

- (AppConfig*)parseConfig:(NSString*) configPath {
	AppConfig *config = [[AppConfig alloc] init];
	AppConfigParser *parser = [[AppConfigParser alloc] init];
	parser.configBeingParsed = config;
	NSXMLParser *xmlParser = [NSXMLParser alloc];
	NSURL *configUrl = [NSURL fileURLWithPath: configPath];
	
	//parse config
	[xmlParser initWithContentsOfURL:configUrl];
	[xmlParser setDelegate:parser];
	BOOL success = [xmlParser parse];
	return success?config:nil;
}

- (void)getAd:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	[NSThread detachNewThreadSelector:@selector(getAdWorker:) toTarget:self withObject:arguments];	
}

//called by getAd to run in worker thread
- (void)getAdWorker:(NSMutableArray*)arguments {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *adName = [arguments objectAtIndex:0];
	NSString *configUrl = [arguments objectAtIndex:1];
	NSString *callbackId = [arguments objectAtIndex:2];
	
	BOOL success = NO;
	NSString* currentAdBaseDir = [[AppMobiDelegate baseDirectory] stringByAppendingPathComponent:adName];//the top-level directory for this ad
	NSString* currentAdExtractDir = [currentAdBaseDir stringByAppendingPathComponent:@"AppMobiCache"];//the directory ad content gets extracted into
	NSString* oldConfigFile = [currentAdBaseDir stringByAppendingPathComponent:@"appconfig.xml"];//the last ad config that was retrieved
	NSString* newConfigFile = [currentAdBaseDir stringByAppendingPathComponent:@"newconfig.xml"];//the ad config we are about to retrieve
	
	//check if the ad already exists locally
	BOOL hasLocalCopy = [[NSFileManager defaultManager] fileExistsAtPath:oldConfigFile] && [[NSFileManager defaultManager] fileExistsAtPath:[currentAdExtractDir stringByAppendingPathComponent:@"index.html"]];
	
	//if it doesnt already exist, create directory structure
	[[NSFileManager defaultManager] createDirectoryAtPath:currentAdExtractDir withIntermediateDirectories:YES attributes:nil error:nil];
		
	//retrieve and parse the latest config
	configUrl = [NSString stringWithFormat:@"%@%c%@%@", configUrl, ([configUrl rangeOfString:@"?"].location!=NSNotFound)?'&':'?', @"platform=ios&deviceid=", [[UIDevice currentDevice] uniqueIdentifier]];
	BOOL retrievedNewConfig = [self downloadConfig:configUrl configPath:newConfigFile];
	
	if(!retrievedNewConfig) {
		//if unable to retrieve updated config, set success based on whether we have a previous version of the ad
		success = hasLocalCopy;
	} else {
		//if retrieved updated config, parse it and continue
		AppConfig* newConfig = [self parseConfig:newConfigFile];
		
		//has a version of this ad been previously retrieved?
		if(hasLocalCopy) {
			AppConfig* oldConfig = [self parseConfig:oldConfigFile];
			//if so, check if there is an update for the ad
			if(newConfig.appVersion>oldConfig.appVersion) {
				success = [self getAndExtractAdBundle:newConfig adDir:currentAdBaseDir oldConfigFile:oldConfigFile newConfigFile:newConfigFile];
			} else {
				success = hasLocalCopy;
			}
		} else {
			//otherwise, just get it
			success = [self getAndExtractAdBundle:newConfig adDir:currentAdBaseDir oldConfigFile:oldConfigFile newConfigFile:newConfigFile];
		}
	}
	
	NSURL *url = [NSURL fileURLWithPath:[currentAdExtractDir stringByAppendingPathComponent:@"index.html"]];
	NSString *path = [url description];	
	
	//after retrieving ad as required, inject an event to let js ad framework know the ad is available
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.advertising.ad.load',true,true);e.identifier='%@';e.path='%@';e.success=%@;document.dispatchEvent(e);", callbackId, path, success?@"true":@"false"];
	[webView injectJS:js];
	
	[pool release];	
}

@end

