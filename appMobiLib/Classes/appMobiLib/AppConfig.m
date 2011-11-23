//
//  Config.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

@synthesize bParsed, paymentsVersion, configRevision, appVersion, bundleURL, cacheURL, configURL, servicesURL, appName, pkgName, relName, analyticsID, analyticsURL, siteURL, siteIcon;
@synthesize appDirectory, jsVersion, jsURL, pushServer, hasCaching, hasStreaming, hasAnalytics, hasAdvertising, hasPush, hasPayments, hasUpdates, hasOAuth, bookmarkURL, siteName, siteBook;
@synthesize paymentMerchant, paymentIcon, paymentsURL, paymentServer, paymentCallback, baseDirectory, appType, appTitle, updateType, updateMessage, servicesVersion, hasSpeech, superType;

- (id) initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
		[self setConfigRevision:[coder decodeIntForKey:@"configRevision"]];
		[self setAppVersion:[coder decodeIntForKey:@"appVersion"]];
		[self setUpdateType:[coder decodeIntForKey:@"updateType"]];
		[self setServicesVersion:[coder decodeIntForKey:@"servicesVersion"]];
		[self setPaymentsVersion:[coder decodeIntForKey:@"paymentsVersion"]];
		[self setBaseDirectory:[coder decodeObjectForKey:@"baseDirectory"]];
		[self setAppDirectory:[coder decodeObjectForKey:@"appDirectory"]];
		[self setBundleURL:[coder decodeObjectForKey:@"bundleURL"]];
		[self setCacheURL:[coder decodeObjectForKey:@"cacheURL"]];
		[self setConfigURL:[coder decodeObjectForKey:@"configURL"]];
		[self setServicesURL:[coder decodeObjectForKey:@"servicesURL"]];
		[self setBookmarkURL:[coder decodeObjectForKey:@"bookmarkURL"]];
		[self setAppName:[coder decodeObjectForKey:@"appName"]];
		[self setAppTitle:[coder decodeObjectForKey:@"appTitle"]];
		[self setRelName:[coder decodeObjectForKey:@"relName"]];
		[self setPkgName:[coder decodeObjectForKey:@"pkgName"]];
		[self setAppType:[coder decodeObjectForKey:@"apptype"]];
		[self setSuperType:[coder decodeObjectForKey:@"superType"]];
		[self setAnalyticsURL:[coder decodeObjectForKey:@"analyticsURL"]];
		[self setJsVersion:[coder decodeObjectForKey:@"jsVersion"]];
		[self setJsURL:[coder decodeObjectForKey:@"jsURL"]];
		[self setPushServer:[coder decodeObjectForKey:@"pushServer"]];
		[self setPaymentsURL:[coder decodeObjectForKey:@"paymentsURL"]];
		[self setPaymentServer:[coder decodeObjectForKey:@"paymentServer"]];
		[self setPaymentMerchant:[coder decodeObjectForKey:@"paymentMerchant"]];
		[self setPaymentCallback:[coder decodeObjectForKey:@"paymentCallback"]];
		[self setPaymentIcon:[coder decodeObjectForKey:@"paymentIcon"]];
		[self setUpdateMessage:[coder decodeObjectForKey:@"updateMessage"]];
		[self setSiteURL:[coder decodeObjectForKey:@"siteURL"]];
		[self setSiteIcon:[coder decodeObjectForKey:@"siteIcon"]];
		[self setSiteName:[coder decodeObjectForKey:@"siteName"]];
		[self setSiteBook:[coder decodeObjectForKey:@"siteBook"]];
		[self setBParsed:[coder decodeBoolForKey:@"bParsed"]];
		[self setHasCaching:[coder decodeBoolForKey:@"hasCaching"]];
		[self setHasStreaming:[coder decodeBoolForKey:@"hasStreaming"]];
		[self setHasAnalytics:[coder decodeBoolForKey:@"hasAnalytics"]];
		[self setHasAdvertising:[coder decodeBoolForKey:@"hasAdvertising"]];
		[self setHasPush:[coder decodeBoolForKey:@"hasPush"]];
		[self setHasPayments:[coder decodeBoolForKey:@"hasPayments"]];
		[self setHasUpdates:[coder decodeBoolForKey:@"hasUpdates"]];
		[self setHasOAuth:[coder decodeBoolForKey:@"hasOAuth"]];
		[self setHasSpeech:[coder decodeBoolForKey:@"hasSpeech"]];
	}
	return self;
}
 
- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:configRevision forKey:@"configRevision"];
	[coder encodeInt:appVersion forKey:@"appVersion"];
	[coder encodeInt:updateType forKey:@"updateType"];
	[coder encodeInt:servicesVersion forKey:@"servicesVersion"];
	[coder encodeInt:paymentsVersion forKey:@"paymentsVersion"];
	[coder encodeObject:baseDirectory forKey:@"baseDirectory"];
	[coder encodeObject:appDirectory forKey:@"appDirectory"];
	[coder encodeObject:bundleURL forKey:@"bundleURL"];
	[coder encodeObject:cacheURL forKey:@"cacheURL"];
	[coder encodeObject:configURL forKey:@"configURL"];
	[coder encodeObject:servicesURL forKey:@"servicesURL"];
	[coder encodeObject:bookmarkURL forKey:@"bookmarkURL"];
	[coder encodeObject:appName forKey:@"appName"];
	[coder encodeObject:appTitle forKey:@"appTitle"];
	[coder encodeObject:relName forKey:@"relName"];
	[coder encodeObject:pkgName forKey:@"pkgName"];
	[coder encodeObject:appType forKey:@"apptype"];
	[coder encodeObject:superType forKey:@"superType"];
	[coder encodeObject:analyticsID forKey:@"analyticsID"];
	[coder encodeObject:analyticsURL forKey:@"analyticsURL"];
	[coder encodeObject:jsVersion forKey:@"jsVersion"];
	[coder encodeObject:jsURL forKey:@"jsURL"];
	[coder encodeObject:pushServer forKey:@"pushServer"];
	[coder encodeObject:paymentsURL forKey:@"paymentsURL"];
	[coder encodeObject:paymentServer forKey:@"paymentServer"];
	[coder encodeObject:paymentMerchant forKey:@"paymentMerchant"];
	[coder encodeObject:paymentCallback forKey:@"paymentCallback"];
	[coder encodeObject:paymentIcon forKey:@"paymentIcon"];
	[coder encodeObject:updateMessage forKey:@"updateMessage"];
	[coder encodeObject:siteURL forKey:@"siteURL"];
	[coder encodeObject:siteIcon forKey:@"siteIcon"];
	[coder encodeObject:siteName forKey:@"siteName"];
	[coder encodeObject:siteBook forKey:@"siteBook"];
	[coder encodeBool:bParsed forKey:@"bParsed"];
	[coder encodeBool:hasCaching forKey:@"hasCaching"];
	[coder encodeBool:hasStreaming forKey:@"hasStreaming"];
	[coder encodeBool:hasAnalytics forKey:@"hasAnalytics"];
	[coder encodeBool:hasAdvertising forKey:@"hasAdvertising"];
	[coder encodeBool:hasPush forKey:@"hasPush"];
	[coder encodeBool:hasPayments forKey:@"hasPayments"];	
	[coder encodeBool:hasUpdates forKey:@"hasUpdates"];	
	[coder encodeBool:hasOAuth forKey:@"hasOAuth"];	
	[coder encodeBool:hasSpeech forKey:@"hasSpeech"];	
}

- (void) dealloc {
	[baseDirectory release];
	[appDirectory release];
	[bundleURL release];
	[cacheURL release];
	[configURL release];
	[servicesURL release];
	[bookmarkURL release];
	[appName release];
	[appTitle release];
	[relName release];
	[pkgName release];
	[appType release];
	[superType release];
	[analyticsID release];
	[analyticsURL release];
	[jsVersion release];
	[jsURL release];
	[pushServer release];
	[paymentsURL release];
	[paymentServer release];
	[paymentMerchant release];
	[paymentCallback release];
	[paymentIcon release];
	[updateMessage release];
	[siteURL release];
	[siteIcon release];
	[siteName release];
	[siteBook release];
	[super dealloc];
}

@end
