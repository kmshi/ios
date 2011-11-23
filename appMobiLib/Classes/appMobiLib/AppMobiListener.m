//
//  AppMobiListener.m
//  appMobiLib
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppMobiListener.h"
#import "AppMobiResponse.h"

@implementation AppMobiListener

- (id)init
{
	self = [super init];
	
	eventListeners = [[NSMutableDictionary alloc] init];
	listenerLock = [[NSLock alloc] init];
	
	return self;
}

- (BOOL)addEventListener:(id<AppMobiListenerDelegate>)delegate forEvent:(NSString *)event;
{
	if( NO == [delegate respondsToSelector:@selector(processResponse:)] ) return NO;
	
	if( event == nil || [event length] == 0 ) return NO;
	
	[listenerLock lock];
	
	[eventListeners setObject:delegate forKey:event];
	
	[listenerLock unlock];
	
	return YES;
}

- (BOOL)removeEventListener:(NSString *)event;
{
	if( event == nil || [event length] == 0 ) return NO;
	
	[listenerLock lock];
	
	if( nil == [eventListeners objectForKey:event] )
	{
		[listenerLock unlock];
		return NO;
	}
	
	[listenerLock lock];
	
	[eventListeners removeObjectForKey:event];
	
	[listenerLock unlock];
	
	return YES;
}

- (void)returnResponse:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DelegateResponse *degres = (DelegateResponse *) sender;
	
	[degres.delegate processResponse:degres.response];

	[pool release];
}

- (void)dispatchEvent:(AppMobiResponse *)response
{
	id<AppMobiListenerDelegate> delegate = nil;
	
	[listenerLock lock];
	
	delegate = [eventListeners objectForKey:response.event];
	
	[listenerLock unlock];
	
	if( nil == delegate ) return;
	
	DelegateResponse *degres = [[[DelegateResponse alloc] init] autorelease];
	degres.delegate = delegate;
	degres.response = response;
	
	[NSThread detachNewThreadSelector:@selector(returnResponse:) toTarget:self withObject:degres];
}

- (void)dealloc
{
	[eventListeners release];
	[listenerLock release];
	[super dealloc];
}

@end

@implementation DelegateResponse

@synthesize delegate;
@synthesize response;

@end
