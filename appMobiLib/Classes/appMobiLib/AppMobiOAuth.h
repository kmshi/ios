//
//  AppMobiPayments.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMobiCommand.h"
#import "GTMOAuthViewControllerTouch.h"

@interface GTMOAuthViewControllerTouch2 : GTMOAuthViewControllerTouch
{
	NSString *requestIndex;
}

@property (nonatomic, retain) NSString *requestIndex;

- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
    requestTokenURL:(NSURL *)requestURL
  authorizeTokenURL:(NSURL *)authorizeURL
     accessTokenURL:(NSURL *)accessURL
     authentication:(GTMOAuthAuthentication *)auth
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector
       requestIndex:(NSString *)requestIndex;

@end

@class OAuthServicesData;
@interface VerificationCallbackData: NSObject {
	NSString *service, *url, *iden, *method, *body, *headers;
}
@property (nonatomic, retain) NSString *service;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *iden;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *headers;
@end

@interface AppMobiOAuth : AppMobiCommand {
	VerificationCallbackData *callbackdata;
	OAuthServicesData *servicesconfig;
	BOOL ready;
	BOOL busy;
}

@property (nonatomic) BOOL ready;

- (void)initializeServiceData:(NSString *)key;

- (void)unauthorizeService:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)getProtectedData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
