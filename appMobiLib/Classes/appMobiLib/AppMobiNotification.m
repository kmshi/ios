//
//  Notification.m
//  AppMobi
//
//  Created by Michael Nachbaur on 16/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "AppMobiNotification.h"
#import "AppMobiAnalytics.h"
#import "AMSResponseParser.h"
#import "AppConfig.h"
#import "Bookmark.h"
#import "AppMobiDelegate.h"
#import "AppMobiWebView.h"
#import "AppMobiViewController.h"
#import "AppMobiPushViewController.h"

@interface NSString (MBBase64)

+ (id)stringWithBase64EncodedString:(NSString *)string;

@end

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (MBBase64)

+ (id)stringWithBase64EncodedString:(NSString *)string;
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:@""];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
	
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [[NSString alloc] initWithBytesNoCopy:bytes length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

@end

@implementation AppMobiNotification

@synthesize strPushPass, strPushUser, strPushEmail, pushUserNotifications;

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiNotification *) [super initWithWebView:webview];
	pushUserNotifications = [[NSMutableDictionary alloc] init];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	strPushUser = [[defaults objectForKey:@"pushUser"] copy];
	strPushPass = [[defaults objectForKey:@"pushPass"] copy];
	strPushEmail = [[defaults objectForKey:@"pushEmail"] copy];
	bAutoPush = [defaults boolForKey:@"pushAuto"];
	
	delegate = [AppMobiDelegate sharedDelegate];
	
	return self;
}

- (void)alert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString* message = [arguments objectAtIndex:0];
	NSString* title   = [arguments objectAtIndex:1];
	NSString* button  = [arguments objectAtIndex:2];
    
    if (!title)
        title = @"Alert";
    if (!button)
        button = @"OK";
    
	UIAlertView *openURLAlert = [[UIAlertView alloc]
								 initWithTitle:title
								 message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
	[openURLAlert show];
	[openURLAlert release];
}

- (void)showBusyIndicator:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    AMLog(@"Activity starting");
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)hideBusyIndicator:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    AMLog(@"Activitiy stopping ");
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)vibrate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)beep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	int numberOfLoops = [(NSString *)[arguments objectAtIndex:0] intValue];
	if( numberOfLoops < 1 ) numberOfLoops = 1;
	
	NSString *bundleBeep = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
	NSData *sampleAudio = [NSData dataWithContentsOfFile:bundleBeep];
	NSError *err;
	player = [[AVAudioPlayer alloc] initWithData:sampleAudio error:&err];
	if(err) AMLog(@"Failed to initialize AVAudioPlayer: %@\n", err);

	player.numberOfLoops = numberOfLoops;
	[player prepareToPlay];
	[player play];
}

- (AMSResponse*)getPushServerResponse:(NSString *)urlString
{
	if(!webView.config.hasPush) return nil;
	
    NSURL *url = [NSURL URLWithString:urlString];
    AMLog(@"***request: %@", url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    //NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //AMLog(@"***response: %@", response);
	
	AMSResponseParser *xmlParser = [[[AMSResponseParser alloc] init] autorelease];
	[xmlParser parseXMLData:data];
	
    return xmlParser.responseBeingParsed;
}

- (void)getUserNotifications:(id)sender
{
	if(!webView.config.hasPush) return;
	
	if( [strPushUser length] == 0 ) return;
	
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.getmessagesforuser&user=%@&passcode=%@&device=%@&appname=%@", webView.config.pushServer, strPushUser, strPushPass, [[UIDevice currentDevice] uniqueIdentifier], webView.config.appName];
	AMSResponse *response = [self getPushServerResponse:urlString];	
	if( response != nil && [response.result compare:@"ok"] == NSOrderedSame )
	{
		for( int i = 0; i < [response.notifications count]; i++ )
		{
			AMSNotification *newnote = (AMSNotification *) [response.notifications objectAtIndex:i];
			AMSNotification *oldnote = (AMSNotification *) [pushUserNotifications valueForKey:[NSString stringWithFormat:@"%d", newnote.ident]];
			if( oldnote == nil )
			{
				if( [newnote.richhtml length] > 0 )
				{
					BOOL encoded = YES;
					encoded &= ( [newnote.richhtml rangeOfString:@" "].location == NSNotFound );
					encoded &= ( [newnote.richhtml rangeOfString:@"<"].location == NSNotFound );
					
					if( encoded == YES ) newnote.richhtml = [NSString stringWithBase64EncodedString:newnote.richhtml];
					newnote.richhtml = [newnote.richhtml stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
				}
				
				if( [newnote.richurl length] > 0 )
				{
					BOOL encoded = YES;
					encoded &= ( [newnote.richurl rangeOfString:@"http"].location == NSNotFound );
					
					if( encoded == YES ) newnote.richurl = [NSString stringWithBase64EncodedString:newnote.richurl];
					newnote.richurl = [newnote.richurl stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
				}			

				[pushUserNotifications setObject:newnote forKey:[NSString stringWithFormat:@"%d", newnote.ident]];
			}
		}
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[pushUserNotifications count]];
	}
}

- (NSString *)getNotificationsString
{
	if(!webView.config.hasPush) return @"";

	if( [strPushUser length] == 0 ) return @"";
	
	NSString *notes = @"";
	NSArray *keys = [pushUserNotifications allKeys];
	for( int i = 0; i < [keys count]; i++ )
	{
		AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:[keys objectAtIndex:i]];
		notes = [notes stringByAppendingFormat:@"{ id : %d, msg : \"%@\", data : \"%@\", userkey : \"%@\", richurl : \"%@\", richhtml : \"%@\", isRich : %@ }, ", note.ident, note.message, note.data, note.userkey, note.richurl, note.richhtml, (note.isrich?@"true":@"false")];
	}
	
	NSString *js = [NSString stringWithFormat:@"AppMobi.notifications = [%@];", notes];
	return js;
}

- (NSString *)getHiddenNotifications:(NSString *)appname
{
	if(!webView.config.hasPush) return @"";
	
	if( [strPushUser length] == 0 ) return @"";
	
	NSString *notes = @"";
	NSArray *keys = [pushUserNotifications allKeys];
	for( int i = 0; i < [keys count]; i++ )
	{
		AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:[keys objectAtIndex:i]];
		if( note.target != nil && [note.target compare:appname] == NSOrderedSame  && note.hidden == YES )
		{
			notes = [notes stringByAppendingFormat:@"{ id : %d, msg : \"%@\", data : \"%@\", userkey : \"%@\", richurl : \"%@\", richhtml : \"%@\", isRich : %@ }, ", note.ident, note.message, note.data, note.userkey, note.richurl, note.richhtml, (note.isrich?@"true":@"false")];
		}
	}
	
	NSString *js = [NSString stringWithFormat:@"AppMobi.notifications = [%@];", notes];
	return js;
}

- (void)updatePushNotifications:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if(!webView.config.hasPush) return;
	[self getUserNotifications:nil];
	
	if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
		NSString *js = [self getNotificationsString];
		js = [js stringByAppendingString:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.receive',true,true);e.success=true;document.dispatchEvent(e);"];
		[webView injectJS:js];
	}
	if([delegate isWebContainer]) {
		AppMobiViewController *vc = [AppMobiViewController masterViewController];
		[vc performSelectorOnMainThread:@selector(refreshBookmarks:) withObject:nil waitUntilDone:NO];
		
		if( vc.modalViewController != nil )
		{
			UINavigationController *navc = (UINavigationController *) vc.modalViewController;
			AppMobiPushViewController *pushvc = (AppMobiPushViewController *) [navc topViewController];
			pushvc.bLoading = NO;
			[pushvc performSelectorOnMainThread:@selector(reload:) withObject:nil waitUntilDone:NO];
		}		
	}
	
	[pool release];
}

- (void)refreshPushNotifications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	// TODO -- allow user to set attributes on auto push viewer
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if(!webView.config.hasPush) return;

	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""] || strPushPass == nil || [strPushPass isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.refreshPushNotifications, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}
	
	[self getUserNotifications:nil];
	
	if([delegate isWebContainer] == NO) {
		NSString *js = [self getNotificationsString];
		js = [js stringByAppendingString:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.refresh',true,true);e.success=true;document.dispatchEvent(e);"];
		[webView injectJS:js];
	}
}

- (void)registerDevice:(NSString *)token withJSEvent:(BOOL)shouldFire forApp:(NSString *)appname
{
	if(!webView.config.hasPush) return;

	NSString *js;
	if( token != nil )
	{
		AMLog(@"token:%@", token);
		
		//persist and update local references
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *strTemp = [defaults objectForKey:@"pushUser"];
		BOOL didUserExist = !(strTemp == nil || [strTemp isEqualToString:@""]);		
		NSString *appName = (appname == nil) ? webView.config.appName : appname;

		NSString *ampushCommand = nil;
		//check if user existed previously or if we just added them
		if(!didUserExist) {
			// add the device and save user
			ampushCommand = @"adddevice";
			[defaults setObject:strPushUser forKey:@"pushUser"];
			[defaults setObject:strPushPass forKey:@"pushPass"];
			[defaults setObject:strPushEmail forKey:@"pushEmail"];
			[defaults setBool:bAutoPush forKey:@"pushAuto"];
			[defaults synchronize];
		} else {
			ampushCommand = @"adddevice";
		}
		if( webView.bIsMobiusPush == YES )
		{
			ampushCommand = @"adddevice&mobius=1";
		}
		//let server know if we are in sandbox or production mode for APN
		NSString *apnMode = @"1";
		#ifdef DEBUG
		apnMode = @"0";
		#endif
		
		AppMobiAnalytics *analytics = (AppMobiAnalytics *) [webView getCommandInstance:@"AppMobiAnalytics"];
		NSString *strModel = [[[UIDevice currentDevice] model] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.%@&user=%@&passcode=%@&deviceid=%@&token=%@&type=iOS&model=%@&production=%@&appname=%@&devicekey=%@",
							   webView.config.pushServer, ampushCommand, strPushUser, strPushPass, [[UIDevice currentDevice] uniqueIdentifier], token, strModel, apnMode, appName, analytics.strDeviceID];
		AMSResponse *response = [self getPushServerResponse:urlString];
		
		if(response!=nil) {
			if([response.result isEqualToString:@"ok"]) {
				//device is registered
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=true;document.dispatchEvent(e);"];
				// get notifications on the server.
				[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(updatePushNotifications:) userInfo:nil repeats:NO];
			} else {
				//device registration failed
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='%@';document.dispatchEvent(e);", response.message];
			}
		} else {
			//an error occurred
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
		}
	} else {
		//an error occurred
		// if token is nil, then it should fire error fn or event.
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
	}

	if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
		//update js object and fire an event
		if (shouldFire) {
			AMLog(@"%@", js);
			[webView injectJS:js];
		}
	}
}

- (void)autoPushSetup:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasPush) return;
}

- (void)autoPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if(!webView.config.hasPush) return;
}

- (void)checkPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	[self checkPushUserInternal:arguments withDict:options];
}

- (AMSResponse*)checkPushUserInternal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	AMSResponse* response = nil;
	
	if(webView.config.hasPush) {

		//params validated in js
		NSString* userID = [arguments objectAtIndex:0];
		NSString* password = [arguments objectAtIndex:1];
		NSString *appName = webView.config.appName;
		
		// mobius hack to add "users" to the real app and not mobius.app
		if( [arguments count] == 4 )
			appName = [arguments objectAtIndex:3];		
		
		// verify against the server using this user
		NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.checkuser&user=%@&passcode=%@&appname=%@", webView.config.pushServer, userID, password, appName];
		response = [self getPushServerResponse:urlString];
		
		NSString *js;
		if (response!=nil && [response.result isEqualToString:@"ok"]) {
			//update local references
			[strPushUser release];
			strPushUser = [userID copy];
			[strPushPass release];
			strPushPass = [password copy];
			[strPushEmail release];
			strPushEmail = [response.email copy];
			
			//valid credentials, enable user and fire success event with email
			if( [arguments count] != 4 ) [delegate enablePushNotifications:self];
			
		} else {
			if(response!=nil) {
				if ([response.message isEqualToString:@"user does not exist"]) {
					//user does not exist
					js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='user does not exist';document.dispatchEvent(e);"];
				} else {
					//user exists, wrong password
					js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='%@';document.dispatchEvent(e);", response.message];
				}
			} else {
				//an error occurred
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
			}

			if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
				//update js object and fire an event
				AMLog(@"%@", js);
				[webView injectJS:js];
			}
		}	
	}
	return response;
}

- (void)addPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;

	[self addPushUserInternal:arguments withDict:options];
}

- (AMSResponse*)addPushUserInternal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	AMSResponse *response = nil;
	if(webView.config.hasPush) {

		//params validated in js
		NSString* userID = [arguments objectAtIndex:0];
		NSString* password = [arguments objectAtIndex:1];
		NSString* email = [arguments objectAtIndex:2];
		NSString *appName = webView.config.appName;
		
		// mobius hack to add "users" to the real app and not mobius.app
		if( [arguments count] == 4 )
			appName = [arguments objectAtIndex:3];
		
		// try to create/add this user
		NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.adduser&user=%@&email=%@&passcode=%@&appname=%@", webView.config.pushServer, userID, email, password, appName];
		response = [self getPushServerResponse:urlString];
		
		NSString *js;
		if (response!=nil && [response.result isEqualToString:@"ok"]) {
			//update local references
			[strPushUser release];
			strPushUser = [userID copy];
			[strPushPass release];
			strPushPass = [password copy];
			[strPushEmail release];
			strPushEmail = [email copy];

			//valid credentials, enable user and fire success event with email
			if( [arguments count] != 4 ) [delegate enablePushNotifications:self];
		} else {
			if(response==nil) {
				//an error occurred
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='An unexpected error occurred'; document.dispatchEvent(e);"];
			} else if ([response.message isEqualToString:@"invalid passcode"]) {
				//user exists, wrong password
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='invalid passcode';document.dispatchEvent(e);"];
				//dont fire success until end when device is registered
			} else {
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.enable',true,true);e.success=false;e.message='error adding user record to database';document.dispatchEvent(e);"];
			}
			if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
				//update js object and fire an event
				AMLog(@"%@", js);
				[webView injectJS:js];
			}
		}	
	}
	return response;
}

- (void)editPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if(!webView.config.hasPush) return;

	//input params validated in js
	NSString* email = [arguments objectAtIndex:0];
	NSString* newpassword = [arguments objectAtIndex:1];
	
	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.editPushUser, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}
	
	// try to create/add this user
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.edituser&user=%@&appname=%@", webView.config.pushServer, strPushUser, webView.config.appName];
	if (email!=0 && ![email isEqualToString:@""]) {
		urlString = [urlString stringByAppendingFormat:@"&email=%@", email];
	}
	urlString = [urlString stringByAppendingFormat:@"&passcode=%@", strPushPass];
	if (newpassword!=0 && ![newpassword isEqualToString:@""]) {
		urlString = [urlString stringByAppendingFormat:@"&newpasscode=%@", newpassword];
	}
	
	AMSResponse *response = [self getPushServerResponse:urlString];
	
	NSString *js;
	if(response!=nil) {
		if ([response.result isEqualToString:@"ok"]) {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.edit',true,true);e.success=true;document.dispatchEvent(e);"];
			
			//update defaults
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			if (email!=0 && ![email isEqualToString:@""]) {
				strPushEmail = email;
				[defaults setObject:email forKey:@"pushEmail"];
			}
			if (newpassword!=0 && ![newpassword isEqualToString:@""]) {
				strPushPass = newpassword;
				[defaults setObject:newpassword forKey:@"pushPass"];
			}
			[defaults synchronize]; 
			
		} else {
			if ([response.message isEqualToString:@"invalid passcode"]) {
				//user exists, wrong password
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.edit',true,true);e.success=false;e.message='invalid passcode';document.dispatchEvent(e);"];
			} else {
				//an unknown error occurred
				js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.edit',true,true);e.success=false;e.message='error adding user record to database';document.dispatchEvent(e);"];
			}
		}
	} else {
		//an error occurred
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.edit',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
	}
	
	if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
		//update js object and fire an event
		AMLog(@"%@", js);
		[webView injectJS:js];
	}
}

- (void)deletePushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;

	if(!webView.config.hasPush) return;
	
	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.deletePushUser, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}
	
	NSString *appName = webView.config.appName;
	
	// mobius hack to add "users" to the real app and not mobius.app
	if( [arguments count] == 1 && [[arguments objectAtIndex:0] length] > 0 )
		appName = [arguments objectAtIndex:0];
	
	// try to create/add this user
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.deletedevice&user=%@&passcode=%@&deviceid=%@&appname=%@", webView.config.pushServer, strPushUser, strPushPass, [[UIDevice currentDevice] uniqueIdentifier], appName];
	
	AMSResponse *response = [self getPushServerResponse:urlString];
	
	NSString *js;
	if(response!=nil && [[AppMobiDelegate sharedDelegate] isWebContainer] == NO ) {
		if ([response.result isEqualToString:@"ok"]) {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.disable',true,true);e.success=true;document.dispatchEvent(e);"];
			
			// remove registration
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			strPushUser = @"";
			[defaults removeObjectForKey:@"pushUser"];						   
			strPushPass = @"";
			[defaults removeObjectForKey:@"pushPass"];
			strPushEmail = @"";
			[defaults removeObjectForKey:@"pushEmail"];
			bAutoPush = NO;
			[defaults removeObjectForKey:@"pushAuto"];
			[defaults synchronize]; 
			
		} else {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.disable',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
		}
	} else {
		//an error occurred
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.disable',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
	}
	
	if([[AppMobiDelegate sharedDelegate] isWebContainer] == NO) {
		//update js object and fire an event
		AMLog(@"%@", js);
		[webView injectJS:js];
	}
}

- (void)sendPushUserPass:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if(!webView.config.hasPush) return;

	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.sendPushUserPass, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}
	
	// request password be sent to email
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.getpasscode&user=%@&appname=%@", webView.config.pushServer, strPushUser, webView.config.appName];
	AMSResponse *response = [self getPushServerResponse:urlString];
	
	NSString *js;
	if(response!=nil) {
		if ([response.result isEqualToString:@"ok"]) {
			//password was sent
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.sendpassword',true,true);e.success=true;document.dispatchEvent(e);"];
		} else {
			//user does not exist
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.sendpassword',true,true);e.success=false;e.message='user does not exist';document.dispatchEvent(e);"];
		}
	} else {
		//an error occurred
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.sendpassword',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
	}		
	
	//update js object and fire an event
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)setPushUserAttributes:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) 
	{
		AppMobiWebView *pushView = [[AppMobiViewController masterViewController] getPushView];
		AppMobiNotification *notification =  (AppMobiNotification *) [pushView getCommandInstance:@"AppMobiNotification"];
		[arguments addObject:webView.config.appName];
		[notification setPushUserAttributes:arguments withDict:options];
		return;
	}
	
	if(!webView.config.hasPush) return;

	NSString* attributes = [arguments objectAtIndex:0];
	attributes = [attributes stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	NSString *appName = webView.config.appName;
	
	// mobius hack to add "users" to the real app and not mobius.app
	if( [arguments count] == 2 )
		appName = [arguments objectAtIndex:1];
	
	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.setPushUserAttributes, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}
	
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.setuserattributes&user=%@&passcode=%@&appname=%@&attributes=%@", webView.config.pushServer, strPushUser, strPushPass, appName, attributes];
	AMSResponse *response = [self getPushServerResponse:urlString];
	
	NSString *js;
	if(response!=nil) {
		if ([response.result isEqualToString:@"ok"]) {
			//password was sent
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.editattributes',true,true);e.success=true;document.dispatchEvent(e);"];
		} else {
			//user does not exist
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.editattributes',true,true);e.success=false;e.message='%@';document.dispatchEvent(e);", response.message];
		}
	} else {
		//an error occurred
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.editattributes',true,true);e.success=false;e.message='An unexpected error occurred';document.dispatchEvent(e);"];
	}
	
	//update js object and fire an event
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)findPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if(!webView.config.hasPush) return;

	//input params validated in js
	NSString* userID = [arguments objectAtIndex:0];
	NSString* email = [arguments objectAtIndex:1];
	
	NSString *urlString = @"";
	if( [userID length] == 0 && [email length] == 0 )
		urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.finduser&appname=%@", webView.config.pushServer, webView.config.appName];
	else if( [userID length] != 0 )
		urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.finduser&user=%@&appname=%@", webView.config.pushServer, userID, webView.config.appName];
	else if( [email length] != 0 )
		urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.finduser&email=%@&appname=%@", webView.config.pushServer, email, webView.config.appName];
	AMSResponse *response = [self getPushServerResponse:urlString];
	
	NSString *js;
	if( response != nil ) {
		if( [response.result compare:@"ok"] == NSOrderedSame )
		{	
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.find',true,true);e.success=true;e.userid='%@';document.dispatchEvent(e);", response.user];
		} else {
			js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.find',true,true);e.success=false;e.message='unable to find a user';document.dispatchEvent(e);"];
		}
	} else {
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.user.find',true,true);e.success=false;e.message='an unexpected error occurred';document.dispatchEvent(e);"];
	}

	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)readPushNotifications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO )
	{		
		AppMobiWebView *pushView = [[AppMobiViewController masterViewController] getPushView];
		AppMobiNotification *notification =  (AppMobiNotification *) [pushView getCommandInstance:@"AppMobiNotification"];
		[arguments addObject:webView.config.appName];
		[notification readPushNotifications:arguments withDict:options];
		return;
	}
	
	if(!webView.config.hasPush) return;

	//make sure user is logged in
	if(strPushUser == nil || [strPushUser isEqualToString:@""]) {
		NSString* js = @"throw(\"Error: AppMobi.notification.deletePushNotifications, No push user available.\");";
		AMLog(@"%@", js);
		[webView injectJS:js];
		return;
	}

	//a pipe delimited list of messages
	NSString* notificationIDs = [arguments objectAtIndex:0];
	
	NSArray* tokens = [notificationIDs componentsSeparatedByString:@"|"];	
	NSString* tokenstr = @"";
	
	for( int i = 0; i < [tokens count]; i++ )
	{
		AMSNotification *oldnote = (AMSNotification *) [pushUserNotifications valueForKey:[tokens objectAtIndex:i]];
		if( oldnote != nil )
		{
			if( webView != nil )
			{
				NSString *userkey = oldnote.userkey;
				if( userkey == nil || [userkey length] == 0 ) userkey = @"-";
				[webView autoLogEvent:@"/notification/push/delete.event" withQuery:userkey];
			}
			tokenstr = [tokenstr stringByAppendingFormat:@"%@~", [tokens objectAtIndex:i]];
		}
	}
	if( [tokenstr length] > 0 ) tokenstr = [tokenstr substringToIndex:[tokenstr length]-1];

	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.readmessages&user=%@&passcode=%@&msgs=%@&appname=%@", webView.config.pushServer, strPushUser, strPushPass, tokenstr, webView.config.appName];
	AMSResponse *response = [self getPushServerResponse:urlString];
	NSString *js;
	if( response != nil && [response.result compare:@"ok"] == NSOrderedSame )
	{
		for( int i = 0; i < [tokens count]; i++ )
		{
			AMSNotification *oldnote = (AMSNotification *) [pushUserNotifications valueForKey:[tokens objectAtIndex:i]];
			if( oldnote != nil )
			{
				[pushUserNotifications removeObjectForKey:[tokens objectAtIndex:i]];
			}
		}
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[pushUserNotifications count]];
		
		// new code here to get only hidden in mobius
		if( webView.bIsMobiusPush == YES && [arguments count] == 2 )
		{
			NSString *appname = [arguments objectAtIndex:1];
			js = [self getHiddenNotifications:appname];
		}
		else
		{
			js = [self getNotificationsString];
		}
		js = [js stringByAppendingString:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.delete',true,true);e.success=true;document.dispatchEvent(e);"];
	} else {
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.delete',true,true);e.success=false;e.message='an unexpected error occurred';document.dispatchEvent(e);"];
	}
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)sendPushNotification:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if(!webView.config.hasPush) return;

	//input params validated in js
    NSString* userID = [arguments objectAtIndex:0];
    NSString* message   = [arguments objectAtIndex:1];
    NSString* data  = [arguments objectAtIndex:2];
	
	NSString *urlString = [NSString stringWithFormat:@"%@/?CMD=ampush.sendmessage&user=%@&msg=%@&data=%@&appname=%@", webView.config.pushServer, userID, 
						   [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], webView.config.appName];
	AMSResponse *response = [self getPushServerResponse:urlString];
	NSString *js;
	if( response != nil && [response.result compare:@"ok"] == NSOrderedSame )
	{
		js = [NSString stringWithString:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.send',true,true);e.success=true;document.dispatchEvent(e);"];
	} else {
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.send',true,true);e.success=false;e.message='an unexpected error occurred';document.dispatchEvent(e);"];
	}
	AMLog(@"%@", js);
	[webView injectJS:js];
}

- (NSDictionary *)getCountsPerBookmark
{
	NSMutableDictionary* app2Count = [[NSMutableDictionary alloc] init];
	
	NSArray *keys = [pushUserNotifications allKeys];
	for( int i = 0; i < [keys count]; i++ )
	{
		AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:[keys objectAtIndex:i]];
		NSNumber* count = [app2Count objectForKey:note.target];
		if(count == nil) {
			count = [NSNumber numberWithInt:1];
			[app2Count setObject:count forKey:note.target];
		} else {
			[app2Count setObject:[NSNumber numberWithInt:[count intValue] + 1] forKey:note.target];
		}
	}
	
	return app2Count;
}

- (NSMutableArray *)getAutoNotesForApp:(NSString *)appName
{
	NSMutableArray* appnotes = [[NSMutableArray alloc] init];
	
	NSArray *keys = [pushUserNotifications allKeys];
	for( int i = 0; i < [keys count]; i++ )
	{
		AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:[keys objectAtIndex:i]];
		if( note.target != nil && [note.target compare:appName] == NSOrderedSame && note.hidden == NO )
		{
			[appnotes addObject:note];
		}
	}
	
	return appnotes;
}

- (AMSNotification *)getNoteForID:(NSString *)iden
{
	NSArray *keys = [pushUserNotifications allKeys];
	for( int i = 0; i < [keys count]; i++ )
	{
		AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:[keys objectAtIndex:i]];
		if( iden != nil && note.ident == [iden intValue] )
		{
			return note;
		}
	}
	
	return nil;
}

- (void)showRichPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	if( [AppMobiViewController masterViewController].bRichShowing == YES )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.notification.push.rich.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	
	NSString *notificationID = (NSString *)[arguments objectAtIndex:0];
	int closePortX = [(NSString *)[arguments objectAtIndex:1] intValue];
	int closePortY = [(NSString *)[arguments objectAtIndex:2] intValue];
	int closeLandX = [(NSString *)[arguments objectAtIndex:3] intValue];
	int closeLandY = [(NSString *)[arguments objectAtIndex:4] intValue];
	int closeW = [(NSString *)[arguments objectAtIndex:5] intValue];
	int closeH = [(NSString *)[arguments objectAtIndex:6] intValue];
	
	if( closeW == 0 ) closeW = 36;
	if( closeH == 0 ) closeH = 36;
	
	if( notificationID == nil || [notificationID length] == 0 ) return;
	
	AMSNotification *note = (AMSNotification *) [pushUserNotifications valueForKey:notificationID];
	if( note == nil || note.isrich == NO ) return;
	
	AppMobiViewController *vc = [AppMobiViewController masterViewController];
	[vc showRich:note forApp:webView.config atPort:CGRectMake(closePortX,closePortY,closeW,closeH) atLand:CGRectMake(closeLandX,closeLandY,closeW,closeH)];
}

- (void)closeRichPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.bIsMobiusPush == NO ) return;
	
	AppMobiViewController *vc = [AppMobiViewController masterViewController];
	[vc hideRich:nil];
}

@end
