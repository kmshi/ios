
#import <UIKit/UIKit.h>

@class InvokedCommand;
@class AppConfig;
@class AppMobiCommand;

@interface AppMobiWebView : UIWebView<UIWebViewDelegate>
{
	AppConfig *config;
	NSMutableDictionary *commandObjects;
	NSMutableDictionary *moduleObjects;
	id<UIWebViewDelegate> userDelegate;
	BOOL bIsMobiusPush;
}

@property (retain) AppConfig *config;
@property (assign) BOOL bIsMobiusPush;

- (void)setDelegate:(id<UIWebViewDelegate>)delegate;
- (id<UIWebViewDelegate>)delegate;

- (NSString *)baseDirectory;
- (NSString *)appDirectory;
- (NSString *)webRoot;

- (BOOL)execute:(InvokedCommand *)command;	
- (void)registerCommand:(AppMobiCommand *)command forName:(NSString *)name;
- (id)getCommandInstance:(NSString *)className;
- (id)getModuleInstance:(NSString *)className;

- (void)injectJS:(NSString *)js;
- (void)runApp:(id)sender;
- (void)clearApp:(id)sender;
- (void)autoLogEvent:(NSString *)event withQuery:(NSString *)query;

@end
