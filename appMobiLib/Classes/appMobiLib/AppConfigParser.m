//
//  AppConfigParser.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppConfigParser.h"
#import "AppMobiDelegate.h"

@implementation AppConfigParser

@synthesize configBeingParsed;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"CONFIG"]) {
		//get the revision
		configBeingParsed.configRevision = [[attributeDict objectForKey:@"revision"] integerValue];
		configBeingParsed.appName = [attributeDict objectForKey:@"appname"];
		configBeingParsed.appTitle = [attributeDict objectForKey:@"apptitle"];
		configBeingParsed.pkgName = [attributeDict objectForKey:@"pkgname"];
		configBeingParsed.relName = [attributeDict objectForKey:@"release"];
		configBeingParsed.appType = [attributeDict objectForKey:@"type"];
		configBeingParsed.superType = [attributeDict objectForKey:@"supertype"];
		
		//AMLog(@"Reading attributes :%i,%@,%@", configBeingParsed.configRevision, configBeingParsed.appName, configBeingParsed.pkgName);
	} else if([elementName isEqualToString:@"BUNDLE"]) {
		
		configBeingParsed.appVersion = [[attributeDict objectForKey:@"version"] integerValue];
		
		if([attributeDict objectForKey:@"base"]==nil) {
			configBeingParsed.bundleURL = [attributeDict objectForKey:@"bundleURL"];
			configBeingParsed.cacheURL = [attributeDict objectForKey:@"cacheURL"];
			configBeingParsed.configURL = [attributeDict objectForKey:@"configURL"];
		} else {
			//beta support
			NSString* base = [attributeDict objectForKey:@"base"];
			char separator = ([base rangeOfString:@"?"].location!=NSNotFound)?'&':'?';
			configBeingParsed.bundleURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,[attributeDict objectForKey:@"file"],separator,[[UIDevice currentDevice] uniqueIdentifier]];
			configBeingParsed.cacheURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,@"assetcache.xml",separator,[[UIDevice currentDevice] uniqueIdentifier]];
			configBeingParsed.configURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,@"appconfig.xml",separator,[[UIDevice currentDevice] uniqueIdentifier]];
			configBeingParsed.bookmarkURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,@"bookmark.xml",separator,[[UIDevice currentDevice] uniqueIdentifier]];
		}
		
		configBeingParsed.baseDirectory = [[AppMobiDelegate baseDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", configBeingParsed.appName, configBeingParsed.relName]];
		configBeingParsed.appDirectory = [[AppMobiDelegate appDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", configBeingParsed.appName, configBeingParsed.relName]];

		//AMLog(@"Reading attributes :%i,%@,%@", configBeingParsed.appVersion, configBeingParsed.bundleURL, configBeingParsed.cacheURL, configBeingParsed.configURL);
	} else if([elementName isEqualToString:@"ANALYTICS"]) {
		
		configBeingParsed.analyticsID = [attributeDict objectForKey:@"id"];
		configBeingParsed.analyticsURL = [attributeDict objectForKey:@"server"];
		
		//AMLog(@"Reading attributes :%@, %@", configBeingParsed.analyticsID, configBeingParsed.analyticsURL);
	} else if([elementName isEqualToString:@"UPDATE"]) {
		
		configBeingParsed.updateType = [[attributeDict objectForKey:@"type"] integerValue];
		configBeingParsed.updateMessage = [attributeDict objectForKey:@"message"];
		
		//AMLog(@"Reading attributes :%@, %@", configBeingParsed.analyticsID, configBeingParsed.analyticsURL);
	} else if([elementName isEqualToString:@"JAVASCRIPT"]) {
		
		NSString *strplat = @"iphone";
		NSString *attrib = [attributeDict objectForKey:@"platform"];
		if( attrib != nil && [attrib compare:strplat] == NSOrderedSame )
		{		
			configBeingParsed.jsVersion = [attributeDict objectForKey:@"version"];
			configBeingParsed.jsURL = [attributeDict objectForKey:@"url"];
		}
		
		//AMLog(@"Reading attributes :%@, %@", configBeingParsed.jsVersion, configBeingParsed.jsURL);
	} else if([elementName isEqualToString:@"SECURITY"]) {
		configBeingParsed.hasCaching = [[attributeDict objectForKey:@"hasCaching"] boolValue];
		configBeingParsed.hasStreaming = [[attributeDict objectForKey:@"hasStreaming"] boolValue];
		configBeingParsed.hasAnalytics = [[attributeDict objectForKey:@"hasAnalytics"] boolValue];
		configBeingParsed.hasAdvertising = [[attributeDict objectForKey:@"hasAdvertising"] boolValue];
		configBeingParsed.hasPayments = [[attributeDict objectForKey:@"hasInAppPay"] boolValue];
		configBeingParsed.hasUpdates = [[attributeDict objectForKey:@"hasLiveUpdate"] boolValue];
		configBeingParsed.hasPush = [[attributeDict objectForKey:@"hasPushNotify"] boolValue];
		configBeingParsed.hasOAuth = [[attributeDict objectForKey:@"hasOAuth"] boolValue];
		configBeingParsed.hasSpeech = [[attributeDict objectForKey:@"hasOAuth"] boolValue];
		configBeingParsed.hasSpeech = YES;
		
		//AMLog(@"Reading attributes :%@, %@, %@", (configBeingParsed.hasCaching ? @"YES" : @"NO"), (configBeingParsed.hasStreaming ? @"YES" : @"NO"), (configBeingParsed.hasAnalytics ? @"YES" : @"NO"), (configBeingParsed.hasAdvertising ? @"YES" : @"NO"), (configBeingParsed.hasInAppPay ? @"YES" : @"NO"), (configBeingParsed.hasPush ? @"YES" : @"NO"));
	} else if([elementName isEqualToString:@"NOTIFICATIONS"]) {
		configBeingParsed.pushServer = [attributeDict objectForKey:@"server"];
		
		//AMLog(@"Reading attributes :%@", configBeingParsed.pushServer);
	} else if([elementName isEqualToString:@"PAYMENTS"]) {
		configBeingParsed.paymentServer = [attributeDict objectForKey:@"server"];
		configBeingParsed.paymentCallback = [attributeDict objectForKey:@"callback"];
		configBeingParsed.paymentMerchant = [attributeDict objectForKey:@"merchant"];
		configBeingParsed.paymentIcon = [attributeDict objectForKey:@"icon"];
		NSString* base = [attributeDict objectForKey:@"base"];
		char separator = ([base rangeOfString:@"?"].location!=NSNotFound)?'&':'?';
		configBeingParsed.paymentsVersion = [[attributeDict objectForKey:@"sequence"] integerValue];
		configBeingParsed.paymentsURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,@"payments.xml",separator,[[UIDevice currentDevice] uniqueIdentifier]];
		
		//AMLog(@"Reading attributes :%@, %@, %@, %@", configBeingParsed.paymentServer, configBeingParsed.paymentCallback, configBeingParsed.paymentMerchant, configBeingParsed.paymentIcon);
	} else if([elementName isEqualToString:@"SITE"]) {
		configBeingParsed.siteURL = [attributeDict objectForKey:@"siteurl"];
		configBeingParsed.siteIcon = [attributeDict objectForKey:@"siteicon"];
		configBeingParsed.siteName = [attributeDict objectForKey:@"sitename"];
		configBeingParsed.siteBook = [attributeDict objectForKey:@"bookmarkpage"];
		
		//AMLog(@"Reading attributes :%@, %@", configBeingParsed.siteURL, configBeingParsed.siteIcon);
	} else if([elementName isEqualToString:@"OAUTH"]) {
		NSString* base = [attributeDict objectForKey:@"base"];
		char separator = ([base rangeOfString:@"?"].location!=NSNotFound)?'&':'?';
		configBeingParsed.servicesVersion = [[attributeDict objectForKey:@"sequence"] integerValue];
		configBeingParsed.servicesURL = [NSString stringWithFormat:@"%@/%@%cplatform=ios&deviceid=%@",base,@"services.xml",separator,[[UIDevice currentDevice] uniqueIdentifier]];

		//AMLog(@"Reading attributes :%@, %@, %@, %@", configBeingParsed.paymentServer, configBeingParsed.paymentCallback, configBeingParsed.paymentMerchant, configBeingParsed.paymentIcon);
	}
	//AMLog(@"Processing Element: %@", elementName);
}

@end
