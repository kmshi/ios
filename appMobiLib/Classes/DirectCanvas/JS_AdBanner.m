#import "JS_AdBanner.h"


@implementation JS_AdBanner

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
		isAtBottom = NO;
		wantsToShow = NO;
		isReady = NO;
		
		banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
		banner.delegate = self;
		banner.hidden = YES;
		
		if( [DirectCanvas landscapeMode] ) {
			banner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierLandscape, nil];		
		}
		else {
			banner.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, nil];		
		}
		
		if( argc > 0 && JSValueToBoolean(ctx, argv[0]) ) {
			CGRect frame = banner.frame;
			frame.origin.y = [UIScreen mainScreen].bounds.size.height - 
				frame.size.height -
				([DirectCanvas statusBarHidden] ? 0 : 20);
			banner.frame = frame;
			isAtBottom = YES;
		}
		
		[[DirectCanvas instance] addSubview:banner];
		NSLog(@"AdBanner: init at y %f", banner.frame.origin.y);
	}
	return self;
}

- (void)dealloc {
	[banner removeFromSuperview];
	[banner release];
	[super dealloc];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)theBanner {
	NSLog(@"AdBanner: Ad loaded");
	isReady = YES;
	if( wantsToShow ) {
		[[DirectCanvas instance] bringSubviewToFront:banner];
		banner.hidden = NO;
	}
}

- (void)bannerView:(ADBannerView *)theBanner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"AdBanner: Failed to receive Ad");
	banner.hidden = YES;
}


JS_FUNC( JS_AdBanner, hide, ctx, argc, argv ) {
	banner.hidden = YES;
	wantsToShow = NO;
	return NULL;
}

JS_FUNC( JS_AdBanner, show, ctx, argc, argv ) {
	wantsToShow = YES;
	if( isReady ) {
		[[DirectCanvas instance] bringSubviewToFront:banner];
		banner.hidden = NO;
	}
	return NULL;
}

@end
