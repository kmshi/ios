//  PaymentService.m

#import "PaymentService.h"

@implementation PaymentService

@synthesize name, iden;

- (id)init
{
	self = [super init];
	return self;
}

- (void) dealloc {
	[name release];
	[iden release];
	[super dealloc];
}

@end
