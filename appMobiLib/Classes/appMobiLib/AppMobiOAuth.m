//
//  AppMobiPayments.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiOAuth.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"
#import "AppConfig.h"
#import <EventKit/EventKit.h>
#import "GTMOAuthAuthentication.h"
#import "OAuthService.h"
#import "AppMobiWebView.h"
#import "OAuthServicesData.h"

@implementation GTMOAuthViewControllerTouch2

@synthesize requestIndex;

- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
    requestTokenURL:(NSURL *)requestURL
  authorizeTokenURL:(NSURL *)authorizeURL
     accessTokenURL:(NSURL *)accessURL
     authentication:(GTMOAuthAuthentication *)auth
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector
       requestIndex:(NSString *)index {
	
	self = [super initWithScope:scope 
		language:language 
		requestTokenURL:requestURL 
		authorizeTokenURL:authorizeURL 
		accessTokenURL:accessURL 
		authentication:auth 
		appServiceName:keychainAppServiceName 
		delegate:delegate 
		finishedSelector:finishedSelector];

	self.requestIndex = index;
	return self;
}

- (BOOL)shouldUseKeychain {
  BOOL hasName = ([keychainApplicationServiceName_ length] > 0);
  return hasName;
}

- (void)signIn:(GTMOAuthSignIn *)signIn
finishedWithAuth:(GTMOAuthAuthentication *)auth
				 error:(NSError *)error {
  if (!hasCalledFinished_) {
    hasCalledFinished_ = YES;
		
    if (error == nil) {
      BOOL shouldUseKeychain = [self shouldUseKeychain];
      if (shouldUseKeychain) {
        NSString *appServiceName = [self keychainApplicationServiceName];
        if ([auth canAuthorize]) {
          // save the auth params in the keychain
          [[self class] saveParamsToKeychainForName:appServiceName authentication:auth];
        } else {
          // remove the auth params from the keychain
          [[self class] removeParamsFromKeychainForName:appServiceName];
        }
      }
    }
		
    if (delegate_ && finishedSelector_) {
      SEL sel = finishedSelector_;
      NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation setSelector:sel];
      [invocation setTarget:delegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&auth atIndex:3];
      [invocation setArgument:&requestIndex atIndex:4];
      [invocation setArgument:&error atIndex:5];
      [invocation invoke];
    }
		
    [delegate_ autorelease];
    delegate_ = nil;
		
#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(self, auth, error);
			
      // release the block here to avoid a retain loop on the controller
      [completionBlock_ autorelease];
      completionBlock_ = nil;
    }
#endif
  }
}

@end


@implementation VerificationCallbackData

@synthesize service, url, iden, method, body, headers;

- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[service release];
	[url release];
	[iden release];
	[method release];
	[body release];
	[headers release];
	[super dealloc];
}

@end


@implementation AppMobiOAuth

@synthesize ready;

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiOAuth *) [super initWithWebView:webview];

	callbackdata = [[VerificationCallbackData alloc] init];
	servicesconfig = [[OAuthServicesData alloc] init];
	
	return self;
}

- (void)initializeServiceData:(NSString *)key
{
	servicesconfig.secretkey = [key copy];
	NSData *servicesData = [NSData dataWithContentsOfFile:[webView.config.baseDirectory stringByAppendingPathComponent:@"services.xml"]];
	[servicesconfig initializeServices:servicesData];
	ready = YES;
	
	BOOL hasConfigs = ([servicesconfig.name2Service count] > 0);
	NSString *js = [NSString stringWithFormat:@"AppMobi.oauthAvailable = %@;var e = document.createEvent('Events');e.initEvent('appMobi.oauth.setup',true,true);e.success=%@;document.dispatchEvent(e);", (hasConfigs?@"true":@"false"), (hasConfigs?@"true":@"false")];
	AMLog(@"%@",js);
	[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
}

- (void)returnNotReadyEvent:(NSString *)iden
{
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.unavailable',true,true);e.success=false;e.id='%@';document.dispatchEvent(e);", iden];
	AMLog(@"%@",js);
	[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
	busy = NO;
}

- (void)returnBusyEvent:(NSString *)iden
{
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.busy',true,true);e.success=false;e.id='%@';document.dispatchEvent(e);", iden];
	AMLog(@"%@",js);
	[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
}

- (void)returnErrorEvent:(NSError *)error withData:(NSString *)data
{
	NSString *errorMessage = [NSString stringWithFormat:@"error -- code: %d, localizedDescription: %@", [error code], [error localizedDescription]];
	NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.protected.data',true,true);e.success=false;e.id='%@';e.response='%@';e.error='%@';document.dispatchEvent(e);", callbackdata.iden, data, errorMessage];
	AMLog(@"%@",js);
	[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
	busy = NO;
}

- (void)getProtectedDataWithAccessToken:(GTMOAuthAuthentication*)auth
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	NSData *data = nil;
	BOOL success = NO;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:callbackdata.url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
	
	//if it's a post, set method and body
	if([callbackdata.method caseInsensitiveCompare:@"POST"]==NSOrderedSame) {
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[callbackdata.body dataUsingEncoding:NSASCIIStringEncoding]];
		[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	
	NSString *headers = callbackdata.headers;
	if( [headers length] > 0 )
	{
		int length = 0;
		NSString *field = nil;
		NSString *value = nil;
		
		NSRange range = [headers rangeOfString:@"~"];
		while( range.location != NSNotFound )
		{
			length = [[headers substringToIndex:range.location] intValue];				
			if( length > 0 )
			{
				field = [[headers substringFromIndex:range.location + 1] substringToIndex:length];
			}
			headers = [headers substringFromIndex:range.location + 1 + length];
			
			range = [headers rangeOfString:@"~"];
			length = [[headers substringToIndex:range.location] intValue];
			if( length > 0 )
			{
				value = [[headers substringFromIndex:range.location + 1] substringToIndex:length];
			}
			headers = [headers substringFromIndex:range.location + 1 + length];
			
			if( field != nil && value != nil )
			{
				[request addValue:value forHTTPHeaderField:field];
			}
			
			field = nil;
			value = nil;
			range = [headers rangeOfString:@"~"];
		}
	}
	
	//authorize the request
	[auth authorizeRequest:request];
	
	AMLog(@"%@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
	AMLog(@"%@", [request HTTPMethod]);
	
	//send the request
	data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	//check error
	if(error != nil) {
		//AMLog(@"error -- code: %d, localizedDescription: %@", [error code], [error localizedDescription]);
	} else {
		//check response status
		if([[NSString stringWithFormat:@"%d",[response statusCode]] hasPrefix:@"2"]) {
			success = YES;
		} else {
			AMLog(@"error -- code: %d", [response statusCode]);
			AMLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		}
	}
	
	//inject response
	NSString* js, *responseBody = @"";
	if( data != nil )
	{
		responseBody = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		
		//check for BOM characters, then strip if present
		NSRange xmlRange = [responseBody rangeOfString:@"\u00ef\u00bb\u00bf"];
		if(xmlRange.location == 0 && xmlRange.length == 3) responseBody = [responseBody substringFromIndex:3];		
		
		//escape internal double-quotes
		responseBody = [responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		responseBody = [responseBody stringByReplacingOccurrencesOfString:@"\\\\\"" withString:@"\\\\\\\""];
		
		//replace newline characters
		responseBody = [responseBody stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\n"];
		responseBody = [responseBody stringByReplacingOccurrencesOfString:@"\r" withString:@"\\n"];
		responseBody = [responseBody stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	}
	
	if(success) {		
		js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.protected.data',true,true);e.success=true;e.id='%@';e.response=\"%@\";document.dispatchEvent(e);", callbackdata.iden, responseBody];
		AMLog(@"%@",js);
		[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
	} else {
		[self returnErrorEvent:error withData:responseBody];
	}
	
	busy = NO;
	[pool release];
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController finishedWithAuth:(GTMOAuthAuthentication *)auth error:(NSError *)error
{
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	if (error != nil) {		
		// Authentication failed
		[self returnErrorEvent:error withData:@""];
		busy = NO;
	} else {
		// Authentication succeeded
		[NSThread detachNewThreadSelector:@selector(getProtectedDataWithAccessToken:) toTarget:self withObject:auth];	
	}
}

- (void)unauthorizeService:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( webView.config.hasOAuth == NO ) return;
	
	if( ready == NO )
	{
		[self returnNotReadyEvent:@""];
		return;
	}
	
	if( busy == YES )
	{
		[self returnBusyEvent:@""];
		return;
	}
	
	busy = YES;
	NSString *service = (NSString *)[arguments objectAtIndex:0];
	
	// segment service per app
	NSString *servicekey = [NSString stringWithFormat:@"%@.%@", webView.config.appName, service];
	
	//get service from map
	BOOL didUnauth = NO;
	OAuthService *authservice = [servicesconfig.name2Service objectForKey:service];
	if( authservice != nil )
	{
		didUnauth = [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:servicekey];		
		
		if( didUnauth == NO )
		{
			NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.unauthorize',true,true);e.success=false;e.service='%@';e.error='This service wasn\'t already authorized.';document.dispatchEvent(e);", service];
			AMLog(@"%@",js);
			[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
		}
		else
		{	
			NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.unauthorize',true,true);e.success=true;e.service='%@';document.dispatchEvent(e);", service];
			AMLog(@"%@",js);
			[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
		}
	}
	else
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.unauthorize',true,true);e.success=false;e.service='%@';e.error='This is not a configured OAuth service.';document.dispatchEvent(e);", service];
		AMLog(@"%@",js);
		[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
	}
	
	busy = NO;
}

- (void)downloadProtectedData:(NSMutableArray*)arguments
{
	callbackdata.service = (NSString *)[arguments objectAtIndex:0];
	callbackdata.url = (NSString *)[arguments objectAtIndex:1];	
	callbackdata.iden = (NSString *)[arguments objectAtIndex:2];
	callbackdata.method = (NSString *)[arguments objectAtIndex:3];
	callbackdata.body = (NSString *)[arguments objectAtIndex:4];
	callbackdata.headers = (NSString *)[arguments objectAtIndex:5];
	
	// segment service per app
	NSString *servicekey = [NSString stringWithFormat:@"%@.%@", webView.config.appName, callbackdata.service];
	
	//get service from map
	OAuthService *service = [servicesconfig.name2Service objectForKey:callbackdata.service];
	
	if( service == nil )
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.oauth.protected.data',true,true);e.success=false;e.id='%@';e.response='';e.error='%@ is not a configured OAuth service.';document.dispatchEvent(e);", callbackdata.iden, callbackdata.service];
		AMLog(@"%@",js);
		[webView performSelectorOnMainThread:@selector(injectJS:) withObject:js waitUntilDone:NO];
		busy = NO;
		return;
	}
	
	//get auth
	NSString *appKey = service.appKey;
	NSString *secret = service.secret;
	
	GTMOAuthAuthentication *auth = [[[GTMOAuthAuthentication alloc] 
									 initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1 consumerKey:appKey privateKey:secret] autorelease];
	
	auth.serviceProvider = servicekey;
	
	// set the callback URL to which the site should redirect, and for which
	// the OAuth controller should look to determine when sign-in has
	// finished or been canceled
	//
	// This URL does not need to be for an actual web page - just used to intercept redirect
	[auth setCallback:@"http://www.example.com/OAuthCallback"];
	
	//scope is used for google services - just init with placeholder
	NSString *scope = @"http://api.twitter.com/";
	
	//init the view controller
	GTMOAuthViewControllerTouch *viewController;
	viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:scope
																language:nil
														 requestTokenURL:[NSURL URLWithString:service.requestTokenEndpoint]
													   authorizeTokenURL:[NSURL URLWithString:service.authorizeEndpoint]
														  accessTokenURL:[NSURL URLWithString:service.accessTokenEndpoint]
														  authentication:auth
														  appServiceName:servicekey
																delegate:self
													    finishedSelector:@selector(viewController:finishedWithAuth:error:)]
														autorelease];
	
	BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:servicekey authentication:auth];
	if (didAuth) {
		//we have access token, so get the resource
		[NSThread detachNewThreadSelector:@selector(getProtectedDataWithAccessToken:) toTarget:self withObject:auth];	
	} else {
		// Display the autentication view to get an access token
		[[AppMobiViewController masterViewController] presentModalViewController:viewController animated:YES];
	}
}

//need to move body into thread for quick return
- (void)getProtectedData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( webView.config.hasOAuth == NO ) return;
	
	if( ready == NO )
	{
		[self returnNotReadyEvent:[arguments objectAtIndex:2]];
		return;
	}
	
	if( busy == YES )
	{
		[self returnBusyEvent:[arguments objectAtIndex:2]];
		return;
	}

	busy = YES;
	[self downloadProtectedData:arguments];
}

//to signout: [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kAppServiceName];
- (void) dealloc
{
	[callbackdata release];
	[servicesconfig release];
	[super dealloc];
}

@end
