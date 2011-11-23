//
//  AppMobiListener.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConfig.h"

@class AppMobiResponse;

@protocol AppMobiListenerDelegate <NSObject>

@required
- (void)processResponse:(AppMobiResponse *)response;

@end

@interface AppMobiListener : NSObject {
	NSLock *listenerLock;
	NSMutableDictionary *eventListeners;
}

- (BOOL)addEventListener:(id<AppMobiListenerDelegate>)delegate forEvent:(NSString *)event;
- (BOOL)removeEventListener:(NSString *)event;

- (void)dispatchEvent:(AppMobiResponse *)response;

@end

@interface DelegateResponse : NSObject {
	id<AppMobiListenerDelegate> delegate;
	AppMobiResponse *response;
}

@property (nonatomic, assign) id<AppMobiListenerDelegate> delegate;
@property (nonatomic, assign) AppMobiResponse *response;

@end