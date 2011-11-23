
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class AppMobiNotification;
@class AMSNotification;
@class AppConfig;

@interface AppMobiPushViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
	UITableView *myTableView;
	AppMobiNotification *notification;
	AppConfig *config;
	NSMutableArray *notifications;
	AMSNotification *delnote;
	NSIndexPath *delindex;
	BOOL bReload;
	BOOL bLoading;
}

@property (nonatomic) BOOL bReload;
@property (nonatomic) BOOL bLoading;
@property (nonatomic, assign) AppMobiNotification *notification;
@property (nonatomic, assign) AppConfig *config;

- (void)reload:(id)sender;

@end
