//
//  InvokedUrlCommand.h
//  AppMobi
//
//  Created by Shazron Abdullah on 13/08/09.
//  Copyright 2009 Nitobi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InvokedCommand : NSObject {
	NSString* command;
	NSString* className;
	NSString* methodName;
	NSMutableArray* arguments;
	NSMutableDictionary* options;
}

@property(retain) NSMutableArray* arguments;
@property(retain) NSMutableDictionary* options;
@property(copy) NSString* command;
@property(copy) NSString* className;
@property(copy) NSString* methodName;

+ (InvokedCommand*) newFromUrl:(NSURL*)url;

- (void) dealloc;

@end
