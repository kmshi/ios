//
//  AppConfig.h
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface AppConfig: NSObject <NSCoding> {
	
	NSInteger configRevision;
	NSInteger appVersion;
	NSInteger updateType;
	NSInteger servicesVersion;
	NSInteger paymentsVersion;
	NSString *baseDirectory;
	NSString *appDirectory;
	NSString *bundleURL;
	NSString *cacheURL;
	NSString *configURL;
	NSString *servicesURL;
	NSString *bookmarkURL;
	NSString *appName;
	NSString *appTitle;
	NSString *relName;
	NSString *pkgName;
	NSString *appType;
	NSString *superType;
	NSString *analyticsID;
	NSString *analyticsURL;
	NSString *jsVersion;
	NSString *jsURL;
	NSString *pushServer;
	NSString *paymentsURL;
	NSString *paymentServer;
	NSString *paymentMerchant;
	NSString *paymentCallback;
	NSString *paymentIcon;
	NSString *updateMessage;
	NSString *siteURL;
	NSString *siteIcon;
	NSString *siteName;
	NSString *siteBook;
	BOOL bParsed;
	BOOL hasCaching;
	BOOL hasStreaming;
	BOOL hasAnalytics;
	BOOL hasAdvertising;
	BOOL hasPush;
	BOOL hasPayments;
	BOOL hasUpdates;
	BOOL hasOAuth;
	BOOL hasSpeech;
}

@property (nonatomic, readwrite) NSInteger configRevision;
@property (nonatomic, readwrite) NSInteger appVersion;
@property (nonatomic, readwrite) NSInteger updateType;
@property (nonatomic, readwrite) NSInteger servicesVersion;
@property (nonatomic, readwrite) NSInteger paymentsVersion;
@property (nonatomic, retain) NSString *baseDirectory;
@property (nonatomic, retain) NSString *appDirectory;
@property (nonatomic, retain) NSString *bundleURL;
@property (nonatomic, retain) NSString *cacheURL;
@property (nonatomic, retain) NSString *configURL;
@property (nonatomic, retain) NSString *servicesURL;
@property (nonatomic, retain) NSString *bookmarkURL;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *appTitle;
@property (nonatomic, retain) NSString *relName;
@property (nonatomic, retain) NSString *pkgName;
@property (nonatomic, retain) NSString *appType;
@property (nonatomic, retain) NSString *superType;
@property (nonatomic, retain) NSString *analyticsID;
@property (nonatomic, retain) NSString *analyticsURL;
@property (nonatomic, retain) NSString *jsVersion;
@property (nonatomic, retain) NSString *jsURL;
@property (nonatomic, retain) NSString *pushServer;
@property (nonatomic, retain) NSString *paymentsURL;
@property (nonatomic, retain) NSString *paymentServer;
@property (nonatomic, retain) NSString *paymentMerchant;
@property (nonatomic, retain) NSString *paymentCallback;
@property (nonatomic, retain) NSString *paymentIcon;
@property (nonatomic, retain) NSString *updateMessage;
@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSString *siteIcon;
@property (nonatomic, retain) NSString *siteName;
@property (nonatomic, retain) NSString *siteBook;
@property (nonatomic, readwrite) BOOL bParsed;
@property (nonatomic, readwrite) BOOL hasCaching;
@property (nonatomic, readwrite) BOOL hasStreaming;
@property (nonatomic, readwrite) BOOL hasAnalytics;
@property (nonatomic, readwrite) BOOL hasAdvertising;
@property (nonatomic, readwrite) BOOL hasPush;
@property (nonatomic, readwrite) BOOL hasPayments;
@property (nonatomic, readwrite) BOOL hasUpdates;
@property (nonatomic, readwrite) BOOL hasOAuth;
@property (nonatomic, readwrite) BOOL hasSpeech;

@end