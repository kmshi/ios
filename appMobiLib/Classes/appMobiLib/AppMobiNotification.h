//
//  Notification.h
//  AppMobi
//
//  Created by Michael Nachbaur on 16/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "AppMobiCommand.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "AppMobiDelegate.h"
#import "Bookmark.h"
#import "AMSResponse.h"

@class AMSNotification;

@interface AppMobiNotification : AppMobiCommand {
	AVAudioPlayer *player;
	NSMutableDictionary *pushUserNotifications;
	NSString *strPushUser;
	NSString *strPushPass;
	NSString *strPushEmail;
	BOOL bAutoPush;
	AppMobiDelegate *delegate;
}

@property (nonatomic, retain) NSString *strPushUser;
@property (nonatomic, retain) NSString *strPushPass;
@property (nonatomic, retain) NSString *strPushEmail;
@property (nonatomic, retain) NSMutableDictionary* pushUserNotifications;

- (void)alert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)showBusyIndicator:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)hideBusyIndicator:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)vibrate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)beep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)autoPushSetup:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)autoPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)checkPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)addPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)editPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)deletePushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)sendPushUserPass:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setPushUserAttributes:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)findPushUser:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)readPushNotifications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)sendPushNotification:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)refreshPushNotifications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)closeRichPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)showRichPushViewer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)registerDevice:(NSString *)token withJSEvent:(BOOL)shouldFire forApp:(NSString *)appname;
- (void)getUserNotifications:(id)sender;
- (NSString *)getNotificationsString;
- (NSString *)getHiddenNotifications:(NSString *)appname;
- (void)updatePushNotifications:(id)sender;
- (AMSResponse*)checkPushUserInternal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (AMSResponse*)addPushUserInternal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (NSDictionary *)getCountsPerBookmark;
- (NSMutableArray *)getAutoNotesForApp:(NSString *)appName;
- (AMSNotification *)getNoteForID:(NSString *)iden;

@end
