//
//  appMobiCache.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"

@class AppMobiCache;

@interface MediaCacheDelegate: NSObject {
	NSString *url;
	NSString *iden;
	NSString *file;
	BOOL bDone;
	BOOL bSuccess;
	int current;
	int length;
	NSFileHandle *myHandle;
	NSTimeInterval lastUpdateTime;
	AppMobiWebView *webView;
	AppMobiCache *parentCache;
}

@property (nonatomic, retain) NSString *iden;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) AppMobiCache *parentCache;
@property (nonatomic) BOOL bDone;
@property (nonatomic) NSTimeInterval lastUpdateTime;

@end

@interface AppMobiCache : AppMobiCommand {
	NSString *cachedMediaDirectory;
	NSMutableDictionary* cookies;
	NSMutableDictionary* mediaCache;
}

@property(nonatomic, retain) NSMutableDictionary* cookies;
@property(nonatomic, retain) NSMutableDictionary* mediaCache;

- (NSString*) allCookies;
- (NSDictionary*) getMediaCacheList;
- (void)downloadToMediaCache:(NSMutableArray*)args;
- (void)finishedDownloadToMediaCache:(NSString*)url toPath:(NSString *)path withFlag:(BOOL)didSucceed forID:(NSString*)iden;
- (void)resetPhysicalMediaCache;

- (void)setCookie:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)removeCookie:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)clearAllCookies:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)addToMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)removeFromMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)clearMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
