
#import "AppMobiPushViewController.h"
#import "AppMobiDelegate.h"
#import "AMSNotification.h"
#import "AppMobiNotification.h"
#import "AppMobiViewController.h"
#import "AppMobiWebView.h"
#import "AppMobiCommand.h"
#import "AppConfig.h"

@implementation AppMobiPushViewController

@synthesize bReload;
@synthesize bLoading;
@synthesize notification;
@synthesize config;

- (void)dealloc
{
	[myTableView release];
	[notifications release];
	[super dealloc];
}

- (void)reload:(id)sender
{
	notifications =  [notification getAutoNotesForApp:config.appName];

	[myTableView reloadData];
}

- (void)loadView
{
	myTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
	myTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	myTableView.delegate = self;
	myTableView.dataSource = self;
	myTableView.sectionIndexMinimumDisplayRowCount=10;

	self.view = myTableView;
	self.title = @"Push Messages";
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(onDone:)] autorelease];
	
	[self reload:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)onDone:(id)sender
{
	[[AppMobiViewController masterViewController] refreshBookmarks:nil];
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	[AppMobiViewController masterViewController].bPushShowing = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	myTableView.editing = editing;
}

- (void)deleteNote:(AMSNotification *)note forIndex:(NSIndexPath *)indexPath
{
	[notification readPushNotifications:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d", note.ident]] withDict:nil];
	
	[notifications removeObjectAtIndex:indexPath.row];
	if( [notifications count] == 0 ) bReload = YES;
	
	NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
	[arr addObject:indexPath];
    [indexPath release];
	[myTableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)checkDelete:(AMSNotification *)note forIndex:(NSIndexPath *)indexPath
{
	delnote = note;
	delindex = [indexPath retain];
	NSString *emessage = [NSString stringWithFormat:@"%@\n\nDo you want to delete this message?", note.message];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Message" message:emessage delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
	[alert show];
	[alert release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int height = 43.0;
	return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	AMSNotification *note = (AMSNotification *) [notifications objectAtIndex:indexPath.row];
	[self checkDelete:note forIndex:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( notification == nil ) return;

	AMSNotification *note = (AMSNotification *) [notifications objectAtIndex:indexPath.row];	
	if( note.isrich == YES )
	{
		AppMobiViewController *vc = [AppMobiViewController masterViewController];
		[vc showRich:note forApp:config atPort:CGRectMake(0,0,36,36) atLand:CGRectMake(0,0,36,36)];
		[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	}
	else
	{
		//[self checkDelete:note forIndex:indexPath];		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Message" message:note.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];		
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 )
	{
		[self deleteNote:delnote forIndex:delindex];
	}
	delindex = nil;
	delnote = nil;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	delindex = nil;
	delnote = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushTableViewCell"];
	if( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PushTableViewCell"] autorelease];
	}
	
	cell.textLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.textColor = [UIColor redColor];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.detailTextLabel.text = @"";
	cell.contentView.backgroundColor = [UIColor whiteColor];
	cell.textLabel.hidden = NO;

	if( notifications == nil || bLoading == YES )
	{
		cell.textLabel.text = @"Loading...";
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{
		AMSNotification *note = (AMSNotification *) [notifications objectAtIndex:indexPath.row];		
		cell.textLabel.text = note.message;		
		if( note.isrich == YES )
		{
			cell.detailTextLabel.text = @"This is a multi-media message.";
		}
	}

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if( notifications == nil || bLoading == YES )
	{
		return 1;
	}
	else
	{
		return [notifications count];
	}
}

@end
