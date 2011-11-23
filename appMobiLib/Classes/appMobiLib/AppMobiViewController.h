
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ZBarSDK.h"
#import <SpeechKit/SpeechKit.h>

@class PlayingView;
@class XMLTrack;
@class Bookmark;
@class AppMobiWebView;
@class AppConfig;
@class AppMobiWebView;
@class AMSNotification;
@class AppMobiNotification;
@class DirectCanvas;

@interface AppMobiViewController : UIViewController <ZBarReaderDelegate, UITextFieldDelegate, SKRecognizerDelegate> {
	DirectCanvas *directCanvas;
	SKRecognizer *nuance;
	
	PlayingView *playerView;
	UIWindow *window;
    AppMobiWebView *webView;
	AppMobiWebView *pushView;
    AppMobiWebView *adfullView;
    AppMobiWebView *remoteView;
	UIButton *remoteClose;
    AppMobiWebView *richView;
	UIButton *richClose;
	UIImageView *richSplash;
	UILabel *richMessage;
	UIActivityIndicatorView *richSpinner;
	UIInterfaceOrientation lastOrientation;

	UIView *appUpdateBlocker;
    UILabel *appUpdateMessage;
	UIImageView *appUpdateSpinner;
		
	UIView *homeView;
	UIImageView *homeBkgBar;
	UIPageControl *homePages;
	
	UIImageView *topUrlBkg;
	UIButton *topOpenSearch;
	UITextField *topUrlField;
	UITextField *topSearchField;
	
	UIView *midWebBar;
	UIActivityIndicatorView *midWebSpinner;
	
	UIImageView *botTabBlk;
	UIImageView *botTabBkg;
	UIImageView *botTabSel;
	UIImageView *botTabWin;
	UIView *botTabBar;
	UIPageControl *tabPages;
	
	UIView *botWebBar;
	UIView *botWebView;
	UIView *botAppView;
	UIButton *botHome;
	UIButton *botTab;
	UIButton *botBack;
	UIButton *botReload;
	UIButton *botCancel;
	UIButton *botPay;
	UIButton *botFwd;
	UIButton *botSettings;
	UIButton *botFav;
	UIButton *botGallery;
	UIButton *botSpeak;
	
	UIView *settingsView;
	UIImageView *settingsHeader;
	UIScrollView *settingsScrollView;
	
	UIView *appView;
	AppMobiWebView *appWebView;
	UIView *appFooter;
	UIImageView *appFooterBkg;
	UIButton *appUpdate;
	UIButton *appClose;
	UIButton *appFavorite;
    UIProgressView *appInstall;
	
	UIView *speakView;
	UIImageView *speakLogo;
	UIButton *speakDone;
	UIButton *speakCancel;
	
	NSMutableArray *homePics;
	NSMutableArray *homeNames;
	NSMutableArray *homeDels;
	NSMutableArray *homeBubbles;
	NSMutableArray *settingsBkgs;
	NSMutableArray *settingsNames;
	NSMutableArray *settingsSwitches;
	
	NSMutableArray *tabPics;
	NSMutableArray *tabDels;	
	NSMutableArray *arTabs;

	UIImageView *homeStartView;
	UIImageView *tabStartView;
	
	NSMutableArray *arTabSpinner;
	NSMutableArray *arUpdSpinner;
	
	NSMutableArray *arAllBookmarks;
	NSMutableArray *arActiveBookmarks;

    BOOL     autoRotate;
	BOOL     bAReality;
	BOOL     bAllShown;
	BOOL     bHomeShown;
	BOOL     bTabShown;
	BOOL     bSetShown;
	BOOL     bSearching;
	BOOL     bRichShowing;
	BOOL	 bRecording;
	BOOL	 bRecCancel;
	BOOL	 bPushShowing;
    BOOL     bInstalling;
    NSString *fixedOrientation;
	CGPoint dragStart;
	NSString *lastURL;
	NSString *runUrl;
	NSString *lastRich;
	NSString *mobiusOnImage;
	NSString *mobiusOffImage;
	NSString *tabOnImage;
	NSString *tabOffImage;
	NSString *setOnImage;
	NSString *setOffImage;
	
	AppConfig *pushConfig;
	AppMobiNotification *pushNote;	
	NSMutableArray *_payArgs;
	Bookmark *delBookmark;
	AppConfig *_payConfig;
	Bookmark *_payBmk;
	Bookmark *_runBmk;
	Bookmark *_installBmk;
	
	double bookmarkMax;
	int bookmarkRows;
	int bookmarkCols;
	double tabMax;
	int startIndex;
	int tabIndex;
	int curTab;
	int pushCount;
	
	NSTimeInterval richStart;
	CGRect rectRemoteClosePort;
	CGRect rectRemoteCloseLand;
	CGRect rectRichClosePort;
	CGRect rectRichCloseLand;
	CGRect rectRichSplashPort;
	CGRect rectRichSplashLand;
	CGRect rectRichSpinnerPort;
	CGRect rectRichSpinnerLand;
	CGRect rectRichMessagePort;
	CGRect rectRichMessageLand;
}

+ (AppMobiViewController *)masterViewController;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation; 
- (void)setAutoRotate:(BOOL) shouldRotate;
- (void)setRotateOrientation:(NSString *) orientation;
- (PlayingView *)getPlayerView;
- (AppMobiWebView *)getWebView;
- (AppMobiWebView *)getPushView;
- (AppMobiWebView *)getActiveWebView;
- (DirectCanvas *)getDirectCanvas;
- (void)resetDirectCanvas:(id)sender;
- (NSString *)getTrackInfo;
- (void)popWebView;
- (void)pushWebView;
- (void)popPlayerView;
- (void)pushPlayerView;
- (void)updateTrackInfo:(XMLTrack *) track;
- (void)fireEvent:(NSString *)jsevent;
- (void)internalInjectJS:(NSString *)js;
- (void)redirect:(NSString *)url;
- (void)updateShoutcastInfo:(XMLTrack *) track;
- (void)checkForWrongOrientation:(id)sender;
- (void)showCamera:(id)sender;
- (void)hideCamera:(id)sender;
- (void)showPushViewer:(AppConfig *)config forNotification:(AppMobiNotification *)notification;
- (void)showRemote:(NSString *)url forApp:(AppConfig *)appconfig atPort:(CGRect)port atLand:(CGRect)land;
- (void)showRich:(AMSNotification *)notification forApp:(AppConfig *)appconfig atPort:(CGRect)port atLand:(CGRect)land;
- (void)hideRemote:(id)sender;
- (void)hideRich:(id)sender;
- (void)scanBarcode:(id)sender;
- (void)closeActiveTab:(id)sender;
- (void)startManifestCaching:(id)sender;
- (void)endManifestCaching:(id)sender;
- (void)showAdFull:(NSString *)url;
- (void)hideAdFull:(id)sender;
- (void)showUpdate:(id)sender;
- (void)hideUpdate:(id)sender;
- (void)updateButtons:(id)sender;
- (void)refreshBookmarks:(id)sender;
- (void)redrawBookmarks:(id)sender;
- (void)pageLoaded:(id)sender;
- (void)richLoaded:(id)sender;
- (void)onHome:(id)sender;
- (void)onRunSite:(id)sender;
- (void)onCloseApp:(id)sender;
- (void)onRunApp:(id)sender;
- (void)updateInstall:(Bookmark *)bookmark withPercent:(double)percent;
- (void)statusInstall:(Bookmark *)bookmark withSuccess:(BOOL)success;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSString *runUrl;
@property (nonatomic, assign) AppConfig *_payConfig;
@property (nonatomic, assign) Bookmark *_payBmk;
@property (nonatomic, assign) Bookmark *_runBmk;
@property (nonatomic, assign) Bookmark *_installBmk;
@property (nonatomic, retain) NSString *fixedOrientation;
@property (nonatomic, assign) BOOL bRichShowing;
@property (nonatomic, assign) BOOL bPushShowing;

@end
