//
//  LoginViewController.h
//  appMobiTest
//

//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {

	IBOutlet UITextField *appNameField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIActivityIndicatorView *loginIndicator;
	IBOutlet UISegmentedControl *environmentSwitch;
	BOOL haveConfig;
	IBOutlet UIButton *useExistingButton;
	IBOutlet UILabel *orLabel;
	IBOutlet UILabel *currentAppLabel;
	IBOutlet UILabel *currentRelLabel;
	IBOutlet UILabel *currentPkgLabel;
	IBOutlet UILabel *currentAppNameLabel;
	IBOutlet UILabel *currentRelNameLabel;
	IBOutlet UILabel *currentPkgNameLabel;
	IBOutlet UILabel *testContainerLabel;
	NSArray *releases;
}

@property (nonatomic, retain) UITextField *appNameField;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIActivityIndicatorView *loginIndicator;
@property (nonatomic, retain) UISegmentedControl *environmentSwitch;
@property BOOL haveConfig;
@property (nonatomic, retain) UIButton *useExistingButton;
@property (nonatomic, retain) UILabel *orLabel;
@property (nonatomic, retain) UILabel *currentAppLabel;
@property (nonatomic, retain) UILabel *currentRelLabel;
@property (nonatomic, retain) UILabel *currentPkgLabel;
@property (nonatomic, retain) UILabel *currentAppNameLabel;
@property (nonatomic, retain) UILabel *currentRelNameLabel;
@property (nonatomic, retain) UILabel *currentPkgNameLabel;
@property (nonatomic, retain) UILabel *testContainerLabel;

- (IBAction)login:(id)sender;

@end
