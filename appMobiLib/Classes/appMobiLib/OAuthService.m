//  OAuthService.m

#import "OAuthService.h"

@implementation OAuthService

@synthesize name, appKey, secret, requestTokenEndpoint, authorizeEndpoint, accessTokenEndpoint, verb;

- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[name release];
	[appKey release];
	[secret release];
	[requestTokenEndpoint release];
	[authorizeEndpoint release];
	[accessTokenEndpoint release];
	[verb release];
	[super dealloc];
}

@end
