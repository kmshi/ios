#import <Foundation/Foundation.h>
#import "iAd/iAd.h"
#import "JS_BaseClass.h"


@interface JS_AdBanner : JS_BaseClass <ADBannerViewDelegate> {
	ADBannerView * banner;
	BOOL isAtBottom, wantsToShow, isReady;
}

@end
