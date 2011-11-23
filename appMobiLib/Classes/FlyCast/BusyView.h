
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"
#import "GADAdSenseAudioParameters.h"
#import "GADDoubleClickParameters.h"

@class PlayingView;
@class CachedAd;
@class AppMobiDelegate;

@interface BusyView : UIView <AVAudioPlayerDelegate, GADAdViewControllerDelegate>
{
	CachedAd *curad;
	PlayingView *myView;
	UIView *busy;
	UIButton *close;
	UIButton *adView;
	UILabel *adLabel;
	BOOL preroll;
	BOOL loaded;
	BOOL triggered;
	BOOL preloading;
	BOOL preloadingfail;
	BOOL popupdone;
	AVAudioPlayer *adPlayer;
	GADAdViewController *myGoogle;
	NSDictionary *attributes;
	int width;
	int height;
	AppMobiDelegate *myDelegate;
	
}

- (id)initWithView:(PlayingView *)view;
- (void)googleaudio:(id)sender;
- (void)pregoogleaudio:(id)sender;
- (void)googledisplay:(id)sender;
- (void)preroll:(id)sender;
- (void)popup:(id)sender;
- (void)inter:(id)sender;
- (void)handleStop:(id)sender;
- (void)resetView:(BOOL)landscape;
- (void)hideLabels:(id)sender;

@property (nonatomic, retain) UIButton *adView;

@end
