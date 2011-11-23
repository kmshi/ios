#import "AppMobiCommand.h"
#import "AppMobiDelegate.h"
#import "AppMobiWebView.h"

@implementation AppMobiCommand

@synthesize webView;

- (id)initWithWebView:(AppMobiWebView *)webview
{
    self = [super init];
    if (self) webView = [webview retain];
    return self;
}

- (void)dealloc
{
	[webView release];
    [super dealloc];
}

@end
