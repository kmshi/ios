//  AppMobiCanvas.m

#import "AppMobiCanvas.h"
#import "AppMobiViewController.h"
#import "AppMobiWebView.h"
#import "DirectCanvas.h"
#import "AppConfig.h"
#import "AppMobiDelegate.h"

@implementation AppMobiCanvas

DirectCanvas* directCanvas;

- (id)initWithWebView:(AppMobiWebView *)webview
{
	self = (AppMobiCanvas *) [super initWithWebView:webview];
	if (!self)
		return self;

	return self;
}

- (void)resetCanvas:(id)sender
{
	[[AppMobiViewController masterViewController] resetDirectCanvas:nil];
	directCanvas = [[AppMobiViewController masterViewController] getDirectCanvas]; //retain?
}

- (void)load:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    if(directCanvas == nil) {
		[self resetCanvas:nil];
    }
    
	NSString *relativeURL = [arguments objectAtIndex:0];
    if( [[AppMobiDelegate sharedDelegate] isWebContainer] == YES && webView.config != nil && [webView.config.siteURL length] > 0 ) {
        [self reset:nil withDict:nil];
        directCanvas.hidden = NO;
        NSString *remotepath = [webView.config.siteURL stringByDeletingLastPathComponent];        
        [directCanvas load2:relativeURL atPath:remotepath];
    } else {
        directCanvas.hidden = NO;
        [directCanvas load:relativeURL];
    }	
}

- (void)reset:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	//detach the old GLView and cancel all timers
	NSString *js = [NSString stringWithFormat:@"AppMobi.context.cancelAllTimers();AppMobi.canvas.context.detach();"];
	[directCanvas injectJSFromString:js];
	
	//hardcode to landscape for now
	[self resetCanvas:nil];
}

- (void)hide:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	[directCanvas hide];
}

- (void)show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	[directCanvas show];
}

- (void)execute:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSString *javascript = [arguments objectAtIndex:0];
	
	// TODO validate javascript
	
	[directCanvas performSelectorOnMainThread:@selector(injectJSFromString:) withObject:javascript waitUntilDone:NO];
}

- (void)eval:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSString *javascript = [arguments objectAtIndex:0];
	
	// TODO validate javascript
	
	[directCanvas performSelectorOnMainThread:@selector(injectJSFromString:) withObject:[NSString stringWithFormat:@"eval(%@)",javascript] waitUntilDone:NO];
}

- (void)setFPS:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSString *fps = [arguments objectAtIndex:0];
	
	// TODO validate fps
	
	NSString* setFPS = [NSString stringWithFormat:@"AppMobi.canvas.context.setFPS(%@);", fps];
	[self execute:[NSMutableArray arrayWithObject:setFPS] withDict:nil];
}

@end
