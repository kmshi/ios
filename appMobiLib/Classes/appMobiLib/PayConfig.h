//
//  PayConfig.h
//  appMobiLib
//
//  Created by Tony Homer on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface PayConfig: NSObject
{
	NSString *keys;
	NSString *pref;
	NSString *data;
	BOOL isVerified;
}

@property (nonatomic, retain) NSString *keys;
@property (nonatomic, retain) NSString *pref;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, readwrite) BOOL isVerified;

@end