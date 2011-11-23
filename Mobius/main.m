//
//  main.m
//  appMobiTest
//
//  Created by Tony Homer on 1/15/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, @"AMApplication", @"AppDelegate");
    [pool release];
    return retVal;
}
