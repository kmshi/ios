//
//  appMobiCache.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "appMobiCache.h"
#import "AppMobiWebView.h"
#import "AppMobiDelegate.h"
#import "PlayingView.h"
#import "AppConfig.h"

@implementation MediaCacheDelegate

@synthesize iden, url, bDone, file, lastUpdateTime, webView, parentCache;

- (id)init
{
	self = [super init];
	return self;
}

- (void)dealloc
{
	[iden release];
	[url release];
	[file release];
	[webView release];
	[parentCache release];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	AMLog(@"%@",[error localizedDescription]);
	[parentCache finishedDownloadToMediaCache:url toPath:nil withFlag:NO forID:iden];
	bDone = YES;
	bSuccess = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if( myHandle == nil )
	{
		[[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
	
		myHandle = [[NSFileHandle fileHandleForUpdatingAtPath:file] retain];
		[myHandle seekToEndOfFile];
	}
	
	current += [data length];
	[myHandle writeData:data];
	
	NSTimeInterval recent = [[NSDate date] timeIntervalSince1970];
	if( recent - lastUpdateTime > 1.0 )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.update',true,true);e.success=true;e.id='%@';e.current=%d;e.total=%d;document.dispatchEvent(e);", iden, current, length];
		AMLog(@"%@",js);
		[webView injectJS:js];
		lastUpdateTime = recent;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	length = response.expectedContentLength;
	bSuccess = YES;
	
	if( [response isKindOfClass:[NSHTTPURLResponse class]] == YES )
	{
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		bSuccess = [[NSString stringWithFormat:@"%d", [httpResponse statusCode]] hasPrefix:@"2"];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[myHandle closeFile];
	[parentCache finishedDownloadToMediaCache:url toPath:file withFlag:bSuccess forID:iden];
	bDone = YES;
}

@end

@implementation AppMobiCache

@synthesize cookies;
@synthesize mediaCache;

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiCache *) [super initWithWebView:webview];
	
	cachedMediaDirectory = [[webView.config.appDirectory stringByAppendingPathComponent:@"_mediacache"] retain];
	//check if directory exists, create it if not
	if(![[NSFileManager defaultManager] fileExistsAtPath:cachedMediaDirectory isDirectory:nil]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachedMediaDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}else if (!webView.config.hasCaching) {
		//flush cache if not authorized
		[self resetPhysicalMediaCache];
	}
	return self;
}

- (NSString*) getFilenameWithURL:(NSString*) url {
	NSString *filename = [url substringFromIndex:[url rangeOfString:@"/" options:NSBackwardsSearch].location+1];
	AMLog(@"%@",filename);
	return filename;
}

//this gets called at startup time, so init stuff happens in here - should be refactored so initialization happens in init
//delete cookies that are past their expires (form: "Sat, 24 Apr 2010 18:20:00 GMT")
- (NSString*) allCookies
{
	if(cookies==nil) {
		cookies = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];			
		NSString *cookieJar = [NSString stringWithFormat:@"%@.cookies", webView.config.appName];
		if([defaults objectForKey:cookieJar]!=nil) {
			[cookies setDictionary:(NSDictionary *)[defaults objectForKey:cookieJar]];
		}
			
		//check for expired cookies
		NSMutableDictionary *newCookies = [[NSMutableDictionary dictionaryWithCapacity:[cookies count]] retain];
		NSDate *now = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		NSArray *keys = [[cookies allKeys] retain];
		for (NSString *key in keys) {
			NSDictionary *cookie = [cookies objectForKey:key];
			NSDate *expires = [cookie objectForKey:@"expires"];
			if(expires==nil){
				[newCookies setObject:cookie forKey:key];
			} else {
				NSComparisonResult result = [now compare:expires];
				if (result != NSOrderedDescending) {
					[newCookies setObject:cookie forKey:key];
				}
			}
		}
		[dateFormatter release];
		[cookies release];
		[keys release];
		cookies = newCookies;
		//put the cookies back in the cookie jar
		[defaults setObject:cookies forKey:cookieJar];
		[defaults synchronize];			
	}
	
	if( [AppMobiDelegate sharedDelegate].isWebContainer == YES && [webView.config.appName compare:@"mobius.app"] == NSOrderedSame )
	{
		// no contacts for anonymous websites
		[cookies removeAllObjects];
	}
	
	//build string
	NSString *jsCookie = @"{";
	NSArray *keys = [[cookies allKeys] retain];
	for (NSString *key in keys) {
		NSDictionary *cookie = [cookies objectForKey:key];
		NSString *value = [cookie objectForKey:@"value"];
		value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
		jsCookie = [jsCookie stringByAppendingString:[NSString stringWithFormat:@"'%@':{value:'%@'}, ", key, value]];
	}	
	jsCookie = [jsCookie stringByAppendingString:@"}"];
	[self retain];
	return jsCookie;
}

- (void)setCookie:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	
	NSString *name = [arguments objectAtIndex:0];
	if(name == nil || name.length == 0) return;//don't allow cookies with no name
	NSString *value = [arguments objectAtIndex:1];
	NSDate *expires = nil;
	if ([arguments count]==3) {
		int daysTillExpiry = [(NSString *)[arguments objectAtIndex:2] intValue];
		if (daysTillExpiry>=0) {
			double secs = daysTillExpiry*24*60*60;
			expires = [NSDate dateWithTimeIntervalSinceNow:secs];
		}
	}
	
	[cookies setObject:[NSDictionary dictionaryWithObjectsAndKeys: value, @"value", expires, @"expires", nil] forKey:name];
	
	NSString *cookieJar = [NSString stringWithFormat:@"%@.cookies", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:cookies forKey:cookieJar];
	[defaults synchronize];
}

//remove the named cookie
- (void)removeCookie:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	NSString *name = [arguments objectAtIndex:0];

	[cookies removeObjectForKey:name];
	
	NSString *cookieJar = [NSString stringWithFormat:@"%@.cookies", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:cookies forKey:cookieJar];
	[defaults synchronize];
}

//remove all cookies
- (void)clearAllCookies:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
	cookies = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	
	NSString *cookieJar = [NSString stringWithFormat:@"%@.cookies", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:cookies forKey:cookieJar];
	[defaults synchronize];
}


//this gets called at startup time, so init stuff happens in here
- (NSDictionary*)getMediaCacheList
{
	if( webView.config == nil && cachedMediaDirectory == nil ) return [NSMutableDictionary dictionaryWithCapacity:1];
	AMLog(@"getMediaCacheList -- %@", cachedMediaDirectory);
	
	NSArray *physicalMediaCache = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachedMediaDirectory error:nil];
	AMLog(@"****physical media cache****: %@",[physicalMediaCache description]);
	
	if(mediaCache==nil) {
		mediaCache = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSString *mediaJar = [NSString stringWithFormat:@"%@.media", webView.config.appName];
		if([defaults objectForKey:mediaJar]!=nil) {
			[mediaCache setDictionary:(NSDictionary *)[defaults objectForKey:mediaJar]];
		}
	}
	[self retain];
	return mediaCache;
}

- (void)resetPhysicalMediaCache
{
	NSError *err = nil;
	//delete the media cache directory
	[[NSFileManager defaultManager] removeItemAtPath:cachedMediaDirectory error:&err];//what if it cant be deleted?
	if(err!=nil)AMLog(@"%@",err);
	//create an empty directory
	[[NSFileManager defaultManager] createDirectoryAtPath:cachedMediaDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	
	//empty the dictionary
	mediaCache = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	NSString *mediaJar = [NSString stringWithFormat:@"%@.media", webView.config.appName];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:mediaCache forKey:mediaJar];
	[defaults synchronize];
}

- (void)clearMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasCaching) return;

	[self resetPhysicalMediaCache];
	//update js object and fire an event
	NSString *js = @"AppMobi.mediacache = new Array();var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.clear',true,true);document.dispatchEvent(e);";
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)removeFromMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasCaching) return;

	NSString *url = [arguments objectAtIndex:0];
	NSDictionary *mediaMap = [mediaCache objectForKey:url];
	NSString *path = [mediaMap objectForKey:@"file"];
	NSError *err = nil;
	NSString *js;
	BOOL success = NO;
	
	//try to delete the file
	if(path!=nil) {
		BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];//what if it cant be deleted?
		if(removed) {
			//update the dictionary
			[mediaCache removeObjectForKey:url];
			NSString *mediaJar = [NSString stringWithFormat:@"%@.media", webView.config.appName];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:mediaCache forKey:mediaJar];
			[defaults synchronize];

			success = YES;
		} else {
			if(err!=nil)AMLog(@"%@",err);
		}
	}

	if(success) {
		js = [NSString stringWithFormat:@"var i = 0; while (i < AppMobi.mediacache.length) { if (AppMobi.mediacache[i] == '%@') { AppMobi.mediacache.splice(i, 1); } else { i++; }};var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.remove',true,true);e.success=true;e.url='%@';document.dispatchEvent(e);", url, url, url];
	} else {
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.remove',true,true);e.success=false;e.url='%@';document.dispatchEvent(e);", url];
	}
	
	//update js object and fire an event
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)addToMediaCache:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasCaching) return;

	[NSThread detachNewThreadSelector:@selector(downloadToMediaCache:) toTarget:self withObject:arguments];	
}

//called by addToMediaCache to run in worker thread
- (void)downloadToMediaCache:(NSMutableArray*)arguments
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *url = [arguments objectAtIndex:0];

	NSError *error = nil;
	NSHTTPURLResponse *response;
	NSData *data;
	NSMutableURLRequest *urlRequest = nil;
	
	BOOL hasID = NO;
	if( [arguments count] > 1 )
	{
		NSString *seq = [arguments objectAtIndex:1];
		if( seq != nil && [seq length] > 0 )
			hasID = YES;		
	}
	
	if( hasID == YES )
	{
		urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];

		MediaCacheDelegate *del = [[MediaCacheDelegate alloc] init];
		NSString *mediaPath = [cachedMediaDirectory stringByAppendingPathComponent:[self getFilenameWithURL:url]];
		del.parentCache = self;
		del.webView = webView;
		del.file = mediaPath;
		del.url = url;
		del.iden = [arguments objectAtIndex:1];
		del.lastUpdateTime = [[NSDate date] timeIntervalSince1970] - 0.8;
		[[NSURLConnection connectionWithRequest:urlRequest delegate:del] retain];
		while( !del.bDone )
		{
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.2, false);
		}
	}
	else
	{
		//create the file to write data into
		NSString *mediaPath = [cachedMediaDirectory stringByAppendingPathComponent:[self getFilenameWithURL:url]];
		[[NSFileManager defaultManager] createFileAtPath:mediaPath contents:nil attributes:nil];
		
		/*
		//download the file: allow for up to 3 retries
		*/
		int retries = 3;
		BOOL success = NO;
		while(!success && retries>0) {
			urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			
			data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
			//check if the request succeeded, if so, write out data and increment offset
			if(error != nil) {
				//handle error
				AMLog(@"error -- code: %d, localizedDescription: %@", [error code], [error localizedDescription]);
				[self finishedDownloadToMediaCache:url toPath:nil withFlag:NO forID:nil];
			} else {
				if([[NSString stringWithFormat:@"%d",[response statusCode]] hasPrefix:@"2"]) {
					//write data to disk
					NSFileHandle *myHandle = [NSFileHandle fileHandleForUpdatingAtPath:mediaPath];
					[myHandle seekToEndOfFile];
					[myHandle writeData:data];
					[myHandle closeFile];
					success = YES;
				} else {
					AMLog(@"error -- code: %d", [response statusCode]);
					[self finishedDownloadToMediaCache:url toPath:nil withFlag:NO forID:nil];
				}
			}
			retries--;
		}
		[self finishedDownloadToMediaCache:url toPath:mediaPath withFlag:YES forID:nil];
	}
	
	[pool release];
}

//called by downloadToMediaCache after completion
//update mediaCache, AppMobiMediaCache js object and fire an event
- (void)finishedDownloadToMediaCache:(NSString*)url toPath:(NSString *)path withFlag:(BOOL)didSucceed forID:(NSString*)iden {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *js;

	NSString *idjs = @"";
	if( iden != nil ) idjs = [NSString stringWithFormat:@"e.id='%@';", iden];
	
	if(didSucceed) {
		if([mediaCache objectForKey:url]==nil) {
			[mediaCache setObject:[NSDictionary dictionaryWithObjectsAndKeys: path, @"file", nil] forKey:url];
			NSString *mediaJar = [NSString stringWithFormat:@"%@.media", webView.config.appName];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:mediaCache forKey:mediaJar];
			[defaults synchronize];

			//update js object and fire an event
			js = [NSString stringWithFormat:@"AppMobi.mediacache.push('%@');var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.add',true,true);e.success=true;e.url='%@';%@document.dispatchEvent(e);", url, url, idjs];
		} else {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.add',true,true);e.success=true;e.url='%@';%@document.dispatchEvent(e);", url, idjs];
		}

	} else {
		//fire event
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.cache.media.add',true,true);e.success=false;e.url='%@';%@document.dispatchEvent(e);", url, idjs];
	}
	AMLog(@"%@",js);
	[webView injectJS:js];
	[pool release];
}

- (void) dealloc
{
	[cookies release];
	[mediaCache release];
	[cachedMediaDirectory release];
	[super dealloc];
}

@end
