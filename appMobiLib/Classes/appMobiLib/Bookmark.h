//
//  Bookmark.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppConfig;

@interface Bookmark : NSObject <NSCoding> {
	NSString *name;
	NSString *url;
	NSString *imageurl;
	NSString *appname;
	NSString *relname;
	NSString *appconfigurl;
	NSString *webroot;
	NSString *buypage;
	NSString *paypage;
	NSString *bookpage;
	AppConfig *appconfig;
	UIImage *uiImage;
	int  messages;
    int  percent;
	BOOL isApplication;
	BOOL isDeleted;
	BOOL isDownloading;
	BOOL isInstalling;
	BOOL isInstalled;
	BOOL isPrivate;
	BOOL isFeatured;
	BOOL isUserFav;
	BOOL hasPushOn;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *imageurl;
@property (nonatomic, retain) NSString *appname;
@property (nonatomic, retain) NSString *relname;
@property (nonatomic, retain) NSString *appconfigurl;
@property (nonatomic, retain) NSString *webroot;
@property (nonatomic, retain) NSString *buypage;
@property (nonatomic, retain) NSString *paypage;
@property (nonatomic, retain) NSString *bookpage;
@property (nonatomic, retain) AppConfig *appconfig;
@property (nonatomic, retain) UIImage *uiImage;
@property (nonatomic, readwrite) int messages;
@property (nonatomic, readwrite) int percent;
@property (nonatomic, readwrite) BOOL isDownloading;
@property (nonatomic, readwrite) BOOL isApplication;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) BOOL isInstalling;
@property (nonatomic, readwrite) BOOL isInstalled;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFeatured;
@property (nonatomic, readwrite) BOOL isUserFav;
@property (nonatomic, readwrite) BOOL hasPushOn;

@end

@interface BookmarkConfig: NSObject
{
	NSMutableArray *bookmarks;
	int sequence;
}

@property (nonatomic, retain) NSMutableArray *bookmarks;
@property (nonatomic) int sequence;

@end
