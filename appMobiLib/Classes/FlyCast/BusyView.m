
#import "BusyView.h"
#import "PlayingView.h"
#import "CachedAd.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"

@implementation BusyView

@synthesize adView;

- (id)initWithView:(PlayingView *)view
{
  myDelegate = (AppMobiDelegate *)[[UIApplication sharedApplication] delegate];  
	if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]])
	{
		myView = view;
		
		CGRect frame = [[UIScreen mainScreen] applicationFrame];		
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

		width = 300;
		height = 250;
		
		busy = [[UIView alloc] initWithFrame:frame];
		busy.backgroundColor = [UIColor blackColor];
		busy.alpha = 0.6;
		[self addSubview: busy];
		
		adView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		adView.frame = CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height);	
		[adView addTarget:self action:@selector(onAd:) forControlEvents:UIControlEventTouchUpInside];
		[adView setTitle:@"" forState:UIControlStateNormal];
		[adView setImage:[UIImage imageNamed:@"black.png"] forState:UIControlStateNormal];
		adView.hidden = YES;
		[self addSubview:adView];
		
		adLabel = [[UILabel alloc] initWithFrame:CGRectMake((320-320)/2, (460-250)/2, 320, 30)];
		adLabel.text = @"Advertisement Loading ...";
		adLabel.textColor = [UIColor whiteColor];
		adLabel.backgroundColor = [UIColor clearColor];
		adLabel.font = [UIFont boldSystemFontOfSize:16.0];
		adLabel.hidden = YES;
		adLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:adLabel];
				
		myGoogle = [[GADAdViewController alloc] initWithDelegate:self];
		myGoogle.view.frame = CGRectMake((320-320)/2, (460-250)/2, 320, 250);
		myGoogle.adSize = kGADAdSize300x250;
		myGoogle.view.hidden = YES;
		[self addSubview:myGoogle.view];	
		
		close = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		close.frame = CGRectMake((320-320)/2+295, (frame.size.height-height)/2, 40, 40);	
		[close addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
		[close setTitle:@"" forState:UIControlStateNormal];
		[close setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
		close.hidden = YES;
		[self addSubview:close];	
	}

	return self;
}

- (void)onRotate:(id)sender
{
	UITabBarController *parent = (UITabBarController *)sender;
	BOOL landscape = (parent.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || parent.interfaceOrientation == UIInterfaceOrientationLandscapeRight );
	[self resetView:landscape];
}

- (void)hideLabels:(id)sender
{
	myGoogle.view.hidden = YES;
	adLabel.hidden = YES;
}

- (void)resetView:(BOOL)landscape
{
	if( landscape == YES )
	{
		self.frame = CGRectMake(0, 0, 480, 320);
		busy.frame =  CGRectMake(0, 0, 480, 320);
		adView.frame = CGRectMake((480-width)/2, (300-height), width, height);
		adLabel.frame = CGRectMake((480-300)/2, (300-250)+20, 300, 30);
		myGoogle.view.frame = CGRectMake((480-300)/2, (300-250)+20, 300, 250);
		close.frame = CGRectMake((480-320)/2+275, (300-250)+20-40, 40, 40);
	}
	else
	{
		self.frame = CGRectMake(0, 0, 320, 480);
		busy.frame = CGRectMake(0, 0, 320, 480);
		adView.frame = CGRectMake((320-width)/2, (460-height)/2, width, height);
		adLabel.frame = CGRectMake((320-300)/2, (460-250)/2, 320, 30);
		myGoogle.view.frame = CGRectMake((320-300)/2, (460-250)/2, 300, 250);
		close.frame = CGRectMake((320-320)/2+275, (460-250)/2-40, 40, 40);
	}
}

- (void)onClose:(id)sender
{
	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(finished:) userInfo:nil repeats:NO];
}

- (void)pregoogleaudio:(id)sender
{
	//printf("pregoogleaudio\n");
	curad = (CachedAd *)sender;
	preroll = curad.preroll;
	adLabel.hidden = NO;
	preloading = YES;
	preloadingfail = NO;
	loaded = NO;
	
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"ca-audio-pub-8844122551050209", kGADAdSenseClientID,
				  [NSArray arrayWithObjects:curad.strGoogleID, myDelegate.adSenseChannelID, nil], kGADAdSenseChannelIDs,
				  [NSNumber numberWithInt:0], kGADAdSenseIsTestAdRequest,
				  kGADAdSenseAudioImageAdType, kGADAdSenseAdType,
				  [NSNumber numberWithInt: 30000], kGADAdSenseMaxDuration,
				  [NSNumber numberWithInt: 5000], kGADAdSenseMinDuration,
				  myDelegate.adSenseApplicationAppleID, kGADAdSenseApplicationAppleID,			
				  myDelegate.adSenseAppName, kGADAdSenseAppName,
				  myDelegate.adSenseCompanyName, kGADAdSenseCompanyName,
				  myDelegate.adSenseAppWebContentURL, kGADAdSenseAppWebContentURL,
				  nil];
	
	[myGoogle loadGoogleAd:attributes];
}

- (void)googleaudio:(id)sender
{
	//printf("googleaudio\n");
	curad = (CachedAd *)sender;
	preroll = curad.preroll;
	
	if( preloading == NO )
	{
		adLabel.hidden = NO;
		loaded = NO;

		attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			@"ca-audio-pub-8844122551050209", kGADAdSenseClientID,
			[NSArray arrayWithObjects:curad.strGoogleID, myDelegate.adSenseChannelID, nil], kGADAdSenseChannelIDs,
			[NSNumber numberWithInt:0], kGADAdSenseIsTestAdRequest,
			kGADAdSenseAudioImageAdType, kGADAdSenseAdType,
			[NSNumber numberWithInt: 30000], kGADAdSenseMaxDuration,
			[NSNumber numberWithInt: 5000], kGADAdSenseMinDuration, 
			myDelegate.adSenseApplicationAppleID, kGADAdSenseApplicationAppleID,
			myDelegate.adSenseAppName, kGADAdSenseAppName,
			myDelegate.adSenseCompanyName, kGADAdSenseCompanyName,
			myDelegate.adSenseAppWebContentURL, kGADAdSenseAppWebContentURL,
			nil];
		
		[myGoogle loadGoogleAd:attributes];
	}
	else if( loaded == YES )
	{
		myGoogle.view.hidden = NO;
		preloading = NO;
		[myGoogle showLoadedGoogleAd];
	}
	else if( preloadingfail == YES )
	{
		[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(googleDone:) userInfo:nil repeats:NO];
	}
	else
	{
		triggered = YES;
	}
}

- (void)googledisplay:(id)sender
{
	//printf("googledisplay\n");
	curad = (CachedAd *)sender;
	preroll = curad.preroll;
	adLabel.hidden = NO;
	close.hidden = YES;
	
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				 @"ca-mb-app-pub-8844122551050209", kGADAdSenseClientID,
				 [NSArray arrayWithObjects:curad.strGoogleID, myDelegate.adSenseChannelID, nil], kGADAdSenseChannelIDs,
				 [NSNumber numberWithInt:0], kGADAdSenseIsTestAdRequest,
				 kGADAdSenseImageAdType, kGADAdSenseAdType,
				 myDelegate.adSenseApplicationAppleID, kGADAdSenseApplicationAppleID,			
				 myDelegate.adSenseAppName, kGADAdSenseAppName,
				 myDelegate.adSenseCompanyName, kGADAdSenseCompanyName,
				 myDelegate.adSenseAppWebContentURL, kGADAdSenseAppWebContentURL,
				 nil];
	
	[myGoogle loadGoogleAd:attributes];
}

- (void)handleStop:(id)sender
{
	printf("handleStop\n");
	//myGoogle.view.hidden = YES;
	adLabel.hidden = YES;
	loaded = NO;
	preloading = NO;
}

- (void)googleDone:(id)sender
{
	printf("googleDone\n");
	//myGoogle.view.hidden = YES;
	adLabel.hidden = YES;
	loaded = NO;
	preloading = NO;
	triggered = NO;
	curad.clicked = NO;
	if( preroll == YES )
		[myView prerollDone:curad];
	else
		[myDelegate.myPlayer interDone:curad];
}

- (UIViewController *)viewControllerForModalPresentation:(GADAdViewController *)adController
{
	AMLog(@"viewControllerForModalPresentation: (GADAdViewController *)adController");
	//return [myDelegate.playingView navigationController];
	return [AppMobiViewController masterViewController];
}

- (void)loadSucceeded:(GADAdViewController *)adController withResults:(NSDictionary *) results
{
	//printf("loadSucceeded\n");
	loaded = YES;
	if( preloading == NO )
	{
		myGoogle.view.hidden = NO;
		[myGoogle showLoadedGoogleAd];
	}
	if( triggered == YES && preloading == YES )
	{
		triggered = NO;
		myGoogle.view.hidden = NO;
		[myGoogle showLoadedGoogleAd];
	}
	if( curad.googledisplay == YES )
	{
		close.hidden = NO;
		[NSTimer scheduledTimerWithTimeInterval:curad.duration target:self selector:@selector(finished:) userInfo:nil repeats:NO];
	}
	AMLog(@"loadSucceeded:(GADAdViewController *)adController withResults: %@", results);
}

- (void)loadFailed:(GADAdViewController*)adController withError:(NSError *)error
{
	//printf("loadFailed\n");
	if( preloading == YES )
		preloadingfail = YES;
	else
		[self googleDone:nil];
	AMLog(@"loadFailed:(GADAdViewController*)adController withError: %@", error);
}

- (GADAdClickAction)adControllerActionModelForAdClick: (GADAdViewController *)adController
{
	return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

- (void)adControllerDidCloseWebsiteView:(GADAdViewController *)adController
{
	AMLog(@"adControllerDidCloseWebsiteView:(GADAdViewController *)adController");
}

- (void)showFailed:(GADAdViewController *)adController withError:(NSError *)error
{
	[self googleDone:nil];
	AMLog(@"showFailed:(GADAdViewController *)adController withResults: %@", error);
}

- (void)showSucceeded:(GADAdViewController *)adController withResults:(NSDictionary *) results
{
	[self googleDone:nil];
	AMLog(@"showSucceeded:(GADAdViewController *)adController withResults: %#", results);
}

- (void)adControllerDidExpandAd:(GADAdViewController *)controller
{
	AMLog(@"adControllerDidExpandAd:(GADAdViewController *)controller");
}

- (void)adControllerDidCollapseAd:(GADAdViewController *)controller
{
	AMLog(@"adControllerDidCollapseAd:(GADAdViewController *)controller");
}

- (void)adControllerDidFinishLoading:(GADAdViewController *)adController
{
	//printf("adControllerDidFinishLoading\n");
	if( curad.googledisplay == YES )
	{
		close.hidden = NO;
		myGoogle.view.hidden = NO;
		[NSTimer scheduledTimerWithTimeInterval:curad.duration target:self selector:@selector(finished:) userInfo:nil repeats:NO];
	}
	AMLog(@"adControllerDidFinishLoading:(GADAdViewController *)adController");
}

- (void)preroll:(id)sender
{
	curad = (CachedAd *)sender;
	
	do
	{
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);
	} while( curad.cached == NO );
	
	[adView removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
	[adView addTarget:self action:@selector(onAd:) forControlEvents:UIControlEventTouchUpInside];
	[adView setImage:curad.image forState:UIControlStateNormal];
	adView.hidden = NO;
	preroll = YES;
	
	NSError *aderr = nil;
	adPlayer = [[AVAudioPlayer alloc] initWithData:curad.audio error:&aderr];
	adPlayer.delegate = self;
	[adPlayer play];
}

- (void)popup:(id)sender
{
	printf("popup\n");
	curad = (CachedAd *)sender;
	
	if( curad.googledisplay == YES )
	{
		[self googledisplay:sender];
	}
	else
	{	
		[adView removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
		[adView addTarget:self action:@selector(onPopup:) forControlEvents:UIControlEventTouchUpInside];
		[adView setImage:curad.image forState:UIControlStateNormal];
		adView.hidden = NO;
		close.hidden = NO;
		[NSTimer scheduledTimerWithTimeInterval:curad.duration target:self selector:@selector(finished:) userInfo:nil repeats:NO];
	}
	
	popupdone = NO;
}

- (void)inter:(id)sender
{
	printf("inter\n");
	curad = (CachedAd *)sender;
	
	[adView removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
	[adView addTarget:self action:@selector(onInter:) forControlEvents:UIControlEventTouchUpInside];
	[adView setImage:curad.image forState:UIControlStateNormal];
	adView.hidden = NO;
	preroll = NO;
	
	NSError *aderr = nil;
	adPlayer = [[AVAudioPlayer alloc] initWithData:curad.audio error:&aderr];
	adPlayer.delegate = self;
	[adPlayer play];
}

- (void)finished:(id)sender
{
	if( popupdone == YES ) return;
	
	popupdone = YES;
	curad.clicked = NO;
	[myView popupDone:curad];
	adLabel.hidden = YES;
	myGoogle.view.hidden = YES;
	close.hidden = YES;
	adView.hidden = YES;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	[player release];
	curad.clicked = NO;
	if( preroll == YES )
		[myView prerollError:curad];
	else
		[myDelegate.myPlayer interDone:curad];
	adView.hidden = YES;
	adLabel.hidden = YES;
	close.hidden = YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	printf("audioPlayerDidFinishPlaying\n");
	[player release];
	curad.clicked = NO;
	if( preroll == YES )
		[myView prerollDone:curad];
	else
		[myDelegate.myPlayer interDone:curad];
	adView.hidden = YES;
	adLabel.hidden = YES;
	close.hidden = YES;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	[player play];
}

- (void)onAd:(id)sender
{
	[adPlayer stop];
	[adPlayer release];
	
	curad.clicked = YES;
	[myView prerollDone:curad];
	adView.hidden = YES;
	adLabel.hidden = YES;
	close.hidden = YES;
}

- (void)onPopup:(id)sender
{
	curad.clicked = YES;
	[myView popupDone:curad];
	adView.hidden = YES;
	adLabel.hidden = YES;
	close.hidden = YES;
}

- (void)onInter:(id)sender
{
	curad.clicked = YES;
	[myDelegate.myPlayer interDone:curad];
	adView.hidden = YES;
	adLabel.hidden = YES;
	close.hidden = YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end
