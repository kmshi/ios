/*
 *  Device.m 
 *  Used to display Device centric details handset.
 *
 *  Created by Nitobi on 12/12/08.
 *  Copyright 2008 Nitobi. All rights reserved.
 */

#import "Device.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Connection.h"
#import "AppMobiWebView.h"
#import "JSON.h"

@implementation PGDevice

/**
 * returns a dictionary with various device settings
 *  - gap (version)
 *  - Device platform
 *  - Device version
 *  - Device name (e.g. user-defined name of the phone)
 *  - Device uuid
 */

- (NSDictionary*) deviceProperties
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *phoneGapVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"PhoneGapVersion"];
	NSMutableDictionary *devProps = [NSMutableDictionary dictionaryWithCapacity:4];
	[devProps setObject:[device model] forKey:@"platform"];
	[devProps setObject:[device systemVersion] forKey:@"version"];
	[devProps setObject:[device uniqueIdentifier] forKey:@"uuid"];
	[devProps setObject:[device name] forKey:@"name"];
	[devProps setObject:phoneGapVersion forKey:@"gap"];
	
	id cmd = [webView getCommandInstance:@"com.phonegap.connection"];
	if (cmd && [cmd isKindOfClass:[PGConnection class]]) 
	{
		NSMutableDictionary *connProps = [NSMutableDictionary dictionaryWithCapacity:3];
		if ([cmd respondsToSelector:@selector(type)]) {
			[connProps setObject:[cmd type] forKey:@"type"];
		}
		[devProps setObject:connProps forKey:@"connection"];
	}
	
    NSDictionary *devReturn = [NSDictionary dictionaryWithDictionary:devProps];
    return devReturn;
}

@end
