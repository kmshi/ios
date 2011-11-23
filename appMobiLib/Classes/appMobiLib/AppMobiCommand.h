#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppMobiDelegate;
@class AppMobiWebView;

@interface AppMobiCommand : NSObject {
	AppMobiWebView *webView;
}

- (id)initWithWebView:(AppMobiWebView *)webview;

@property (nonatomic, readonly) UIWebView *webView;

@end
