//
//  Bookmark.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"
#import "AppConfig.h"

@implementation Bookmark

@synthesize name, url, percent, imageurl, appname, relname, appconfigurl, appconfig, webroot, paypage, buypage, bookpage, uiImage;
@synthesize messages, isApplication, isDeleted, isInstalled, isPrivate, isFeatured, isUserFav, hasPushOn, isDownloading, isInstalling;

- (id) initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		[self setName:[coder decodeObjectForKey:@"name"]];
		[self setUrl:[coder decodeObjectForKey:@"url"]];
		[self setImageurl:[coder decodeObjectForKey:@"image"]];
		[self setAppname:[coder decodeObjectForKey:@"appname"]];
		[self setRelname:[coder decodeObjectForKey:@"relname"]];
		[self setAppconfigurl:[coder decodeObjectForKey:@"appconfigurl"]];
		[self setWebroot:[coder decodeObjectForKey:@"webroot"]];
		[self setPaypage:[coder decodeObjectForKey:@"paypage"]];
		[self setBuypage:[coder decodeObjectForKey:@"buypage"]];
		[self setBookpage:[coder decodeObjectForKey:@"bookpage"]];
		[self setMessages:[coder decodeIntForKey:@"messages"]];
		[self setIsApplication:[coder decodeBoolForKey:@"isapplication"]];
		[self setIsDeleted:[coder decodeBoolForKey:@"isdeleted"]];
		[self setIsDownloading:[coder decodeBoolForKey:@"isinstalling"]];
		[self setIsInstalling:[coder decodeBoolForKey:@"isdownloading"]];
		[self setIsInstalled:[coder decodeBoolForKey:@"isinstalled"]];
		[self setIsPrivate:[coder decodeBoolForKey:@"isprivate"]];
		[self setIsFeatured:[coder decodeBoolForKey:@"isfeatured"]];
		[self setIsUserFav:[coder decodeBoolForKey:@"isuserfav"]];
		[self setHasPushOn:[coder decodeBoolForKey:@"haspushon"]];
		NSData *uiImageData = [coder decodeObjectForKey:@"uiImage"];
		[self setUiImage:[[UIImage alloc] initWithData:uiImageData]];
		AppConfig *config = [coder decodeObjectForKey:@"appconfig"];
		[self setAppconfig:config];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:url forKey:@"url"];
	[coder encodeObject:imageurl forKey:@"image"];
	[coder encodeObject:appname forKey:@"appname"];
	[coder encodeObject:relname forKey:@"relname"];
	[coder encodeObject:appconfigurl forKey:@"appconfigurl"];
	[coder encodeObject:webroot forKey:@"webroot"];
	[coder encodeObject:paypage forKey:@"paypage"];
	[coder encodeObject:buypage forKey:@"buypage"];
	[coder encodeObject:bookpage forKey:@"bookpage"];
	[coder encodeInt:messages forKey:@"messages"];
	[coder encodeBool:isApplication forKey:@"isapplication"];
	[coder encodeBool:isDeleted forKey:@"isdeleted"];
	[coder encodeBool:isDownloading forKey:@"isdownloading"];
	[coder encodeBool:isInstalling forKey:@"isinstalling"];
	[coder encodeBool:isInstalled forKey:@"isinstalled"];
	[coder encodeBool:isPrivate forKey:@"isprivate"];
	[coder encodeBool:isFeatured forKey:@"isfeatured"];
	[coder encodeBool:isUserFav forKey:@"isuserfav"];
	[coder encodeBool:hasPushOn forKey:@"haspushon"];
	NSData *data = UIImagePNGRepresentation(uiImage);
	[coder encodeObject:data forKey:@"uiImage"];
	[coder encodeObject:appconfig forKey:@"appconfig"];
}

- (void) dealloc {
	[name release];
	[url release];
	[imageurl release];
	[appname release];
	[relname release];
	[appconfigurl release];
	[webroot release];
	[paypage release];
	[buypage release];
	[bookpage release];
	[appconfig release];
	[super dealloc];
}

@end

@implementation BookmarkConfig

@synthesize bookmarks;
@synthesize sequence;

- (id)init
{
	self = [super init];
	bookmarks = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[bookmarks release];
	[super dealloc];
}

@end
