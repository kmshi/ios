//
//  LoginViewController.m
//  AppMobiTest
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AppMobiDelegate.h"

@implementation LoginViewController

@synthesize appNameField;
@synthesize loginButton;
@synthesize loginIndicator;
@synthesize environmentSwitch;
@synthesize haveConfig;
@synthesize orLabel;
@synthesize useExistingButton;
@synthesize currentAppLabel;
@synthesize currentRelLabel;
@synthesize currentPkgLabel;
@synthesize currentAppNameLabel;
@synthesize currentRelNameLabel;
@synthesize currentPkgNameLabel;
@synthesize testContainerLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	testContainerLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppMobiVersion"];
	
    	appNameField.text = [AppMobiDelegate sharedDelegate].lastApp;
    
	currentAppNameLabel.text = [AppMobiDelegate sharedDelegate].lastApp;
	currentRelNameLabel.text = [AppMobiDelegate sharedDelegate].lastRel;
	currentPkgNameLabel.text = [AppMobiDelegate sharedDelegate].lastPkg;

	if(!haveConfig) {
		useExistingButton.hidden = YES;
		orLabel.hidden = YES;
		currentAppLabel.hidden = YES;
		currentRelLabel.hidden = YES;
		currentPkgLabel.hidden = YES;
		currentAppNameLabel.hidden = YES;
		currentRelNameLabel.hidden = YES;
		currentPkgNameLabel.hidden = YES;
	}
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[appNameField release];
	[loginButton release];
	[loginIndicator release];
	[environmentSwitch release];
	[currentAppLabel release];
	[currentRelLabel release];
	[currentPkgLabel release];
	[currentAppNameLabel release];
	[currentRelNameLabel release];
	[currentPkgNameLabel release];
    [super dealloc];
}

- (void)loginComplete:(id)sender
{
	[[self view] removeFromSuperview];
}

- (void)downloadApp:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	AppMobiDelegate *delegate = [AppMobiDelegate sharedDelegate];
	
	BOOL ok = NO;	
	ok = [delegate downloadInitialApp:delegate.appName andRel:delegate.relName andPkg:delegate.pkgName];

	if( ok == YES )
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:delegate.appName forKey:@"lastApp"];
		[defaults setObject:delegate.relName forKey:@"lastRel"];
		[defaults setObject:delegate.pkgName forKey:@"lastPkg"];
		[defaults synchronize];
		
		[self performSelectorOnMainThread:@selector(loginComplete:) withObject:nil waitUntilDone:NO];
		[NSThread detachNewThreadSelector:@selector(updateWorker:) toTarget:[AppMobiDelegate sharedDelegate] withObject:nil];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(loginFailed:) withObject:@"Unable to download the bundle. Please try restart the application." waitUntilDone:NO];
	}
	
	[pool release];
}

- (void)startDownload:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(downloadApp:) toTarget:self withObject:nil];
	loginIndicator.hidden = NO;
	[loginIndicator startAnimating];
	loginButton.enabled = NO;
	useExistingButton.enabled = NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[AppMobiDelegate sharedDelegate].relName = (NSString *) [releases objectAtIndex:buttonIndex];
	
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(startDownload:) userInfo:nil repeats:NO];
}

-(IBAction) login:(id)sender {
	AMLog(@"%d",[sender tag]);
	
	//check if user clicked login or use current	
	if([sender tag]==1)
	{
		loginIndicator.hidden = NO;
		[loginIndicator startAnimating];
		[AppMobiDelegate sharedDelegate].appName = [[appNameField text] copy];
		[AppMobiDelegate sharedDelegate].pkgName = (([environmentSwitch selectedSegmentIndex]==0)?@"QA":@"PRODUCTION");

		NSString *configURLString = [NSString stringWithFormat:@"https://services.appmobi.com/external/clientservices.aspx?feed=getreleases&app=%@&pw=&platform=ios&deviceid=%@", [AppMobiDelegate sharedDelegate].appName, [[UIDevice currentDevice] uniqueIdentifier]];
		configURLString = [configURLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
		AMLog(@"login -- %@", configURLString);
		NSURL *configURL = [NSURL URLWithString:configURLString];
		NSString *configData = [NSString stringWithContentsOfURL:configURL encoding:NSUTF8StringEncoding error:NULL];
		if( configData == nil || [configData length] == 0 )
		{
			[self performSelectorOnMainThread:@selector(loginFailed:) withObject:@"something is broke" waitUntilDone:NO];
		}
		else
		{
			NSRange range = [configData rangeOfString:@" app=\""];
			if( range.length == 6 )
			{
				NSString *appname = [configData substringFromIndex:range.location + range.length];
				range = [appname rangeOfString:@"\" data=\""];
				appname = [appname substringToIndex:range.location];
				[AppMobiDelegate sharedDelegate].appName = [appname copy];
			}
			
			range = [configData rangeOfString:@" data=\""];
			if( range.length == 7 )
			{
				configData = [configData substringFromIndex:range.location + range.length];
				range = [configData rangeOfString:@"\" />"];
				if( range.length == 4 ) configData = [configData substringToIndex:range.location];
				
				releases = [[configData componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]] retain];
				if([releases count] > 2 )
				{
					UIActionSheet *releasesSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Release" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
					releasesSheet.actionSheetStyle = UIActionSheetStyleDefault;
					
					for( int i = 0; i < [releases count] - 1; i++ )
					{
						[releasesSheet addButtonWithTitle:(NSString *) [releases objectAtIndex:i]];
					}
					UIWindow *key = [[UIApplication sharedApplication] keyWindow];
					if ([AppMobiDelegate isIPad]) {
						//iPad
						[releasesSheet showFromRect:loginButton.frame inView:key animated:YES];
					} else {
						//iPhone
						[releasesSheet showInView:key];
					}
					[releasesSheet release];					
				}
				else
				{
					[AppMobiDelegate sharedDelegate].relName = [(NSString *) [releases objectAtIndex:0] copy];
					[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(startDownload:) userInfo:nil repeats:NO];
				}
			}
			else
			{				
				[self performSelectorOnMainThread:@selector(loginFailed:) withObject:@"Login failed, please check credentials and try again." waitUntilDone:NO];
			}
		}
		
	}
	else if([sender tag]==2)
	{
		AppMobiDelegate *delegate = [AppMobiDelegate sharedDelegate];
		delegate.appName = delegate.lastApp;
		delegate.relName = delegate.lastRel;
		delegate.pkgName = delegate.lastPkg;
		
		[self performSelectorOnMainThread:@selector(loginComplete:) withObject:nil waitUntilDone:NO];
		[NSThread detachNewThreadSelector:@selector(updateWorker:) toTarget:[AppMobiDelegate sharedDelegate] withObject:nil];
	}	
}

- (void)loginFailed:(NSString *)message
{
	NSString* title = @"Error";
	NSString* button = @"OK";
	
	UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
	[openURLAlert show];
	[openURLAlert release];
	[loginIndicator stopAnimating];
	loginIndicator.hidden = YES;	
	loginButton.enabled = YES;
	useExistingButton.enabled = YES;
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


@end
