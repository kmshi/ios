//  AppMobiCanvas.h

#import "AppMobiCommand.h"


@interface AppMobiCanvas : AppMobiCommand {

}

- (void)resetCanvas:(id)sender;
- (id) initWithWebView:(UIWebView*)theWebView;
- (void)load:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)hide:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)execute:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)eval:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)reset:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setFPS:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
