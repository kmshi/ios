
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AppMobiSplashController : UIViewController  {
	UIWindow *window;
	
	UIImageView *imageView;
	UIActivityIndicatorView *activityView;
}

@property (nonatomic, assign) UIWindow *window;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) UIActivityIndicatorView *activityView;

@end
