
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppMobiModule.h"

@interface PhoneGapModule : AppMobiModule {
}

- (void)setup:(AppMobiWebView *)webview;
- (void)initialize:(AppMobiWebView *)webview;

@end
