
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppMobiWebView;

@interface AppMobiModule : NSObject {
}

- (void)setup:(AppMobiWebView *)webview;
- (void)initialize:(AppMobiWebView *)webview;

@end
