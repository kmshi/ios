//
//  AppMobiSplashController.m
//  AppMobi

#import "AppMobiSplashController.h"
#import "AppMobiDelegate.h"

AppMobiSplashController *masters = nil;

@implementation AppMobiSplashController

@synthesize window;
@synthesize imageView;
@synthesize activityView;

- (id) init
{
    self = [super init];
	masters = self;

	return self;
}

+ (AppMobiSplashController*)masterViewController
{
	return masters;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	NSString *initOrient = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIInterfaceOrientation"];
	if( initOrient != nil && [initOrient hasPrefix:@"UIInterfaceOrientationLandscape"] )
	{
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	}
	else
	{
		return (interfaceOrientation == UIInterfaceOrientationPortrait ||
				interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	}
}

- (void)dealloc
{
	[imageView release];
	[activityView release];
	[window release];
	[super dealloc];
}

- (void)loadView
{
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	//frame = CGRectMake(0,0,frame.size.width,frame.size.height);
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view = contentView;
	self.view.backgroundColor = [UIColor clearColor];	
	
	imageView = [[UIImageView alloc] initWithImage:nil];
	imageView.frame = CGRectMake(0, 0, 320, 544);
	imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	imageView.contentMode = UIViewContentModeTopLeft;
	
	imageView.tag = 1;
	[contentView addSubview:imageView];
	
	activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] retain];
	activityView.frame = CGRectMake((frame.size.width-48)/2, (frame.size.height-48)/2, 48, 48);
	activityView.tag = 2;
	[contentView addSubview:activityView];
	[activityView startAnimating];
	
	imageView.image = [[AppMobiDelegate sharedDelegate] updateSplash:nil];
}

- (void)viewDidLoad {
	AMLog(@"amsc -- viewDidLoad");
}

- (void)viewDidUnload {
	AMLog(@"amsc -- viewDidUnload");
}

- (void)viewDidAppear:(BOOL)animated {
	AMLog(@"amsc -- viewDidAppear");
}

@end
