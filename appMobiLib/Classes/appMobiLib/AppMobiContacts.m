
#import "AppMobiContacts.h"
#import <UIKit/UIKit.h>
#import "Categories.h"
#import "AppMobiWebView.h"
#import "AppConfig.h"
#import "AppMobiDelegate.h"
#import "AppMobiViewController.h"

@implementation AppMobiContacts

- (id)initWithWebView:(AppMobiWebView *)webview
{
    self = (AppMobiContacts *) [super initWithWebView:webview];
    if (self) {
    }
	return self;
}

- (NSString *)JSONValueForPerson:(ABRecordRef)recordRef
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *firstName = [(id)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty) autorelease];
	NSString *lastName = [(id)ABRecordCopyValue(recordRef, kABPersonLastNameProperty) autorelease];
	NSString *compositeName = [(id)ABRecordCopyCompositeName(recordRef) autorelease];

	firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	compositeName = [compositeName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
	
	ABMultiValueRef emails = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
	NSString *emailAddresses = @"[]";
	int count = ABMultiValueGetCount(emails);
	if( count > 0 )
	{
		emailAddresses = @"[";
		for( CFIndex i = 0; i < count; i++ )
		{
			NSString *emailstr = [(id)ABMultiValueCopyValueAtIndex(emails, i) autorelease];
			emailstr = [emailstr stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			emailAddresses = [emailAddresses stringByAppendingFormat:@"'%@', ", emailstr];
		}
		emailAddresses = [emailAddresses stringByAppendingString:@"]"];
	}
	CFRelease(emails);
	
	ABMultiValueRef phones = [(id)ABRecordCopyValue(recordRef, kABPersonPhoneProperty) autorelease];
	NSString *phoneNumbers = @"[]";
	count = ABMultiValueGetCount(phones);
	if( count > 0 )
	{
		phoneNumbers = @"[";
		for( CFIndex i = 0; i < count; i++ )
		{
			NSString *phonestr = [(id)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
			phonestr = [phonestr stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			phoneNumbers = [phoneNumbers stringByAppendingFormat:@"'%@', ", phonestr];
		}
		phoneNumbers = [phoneNumbers stringByAppendingString:@"]"];
	}
	CFRelease(phones);
	
	ABMutableMultiValueRef addresses = ABRecordCopyValue(recordRef, kABPersonAddressProperty);
	NSString *streetAddresses = @"[]";
	count = ABMultiValueGetCount(addresses);
	if( count > 0 )
	{
		streetAddresses = @"[";
		for( CFIndex i = 0; i < count; i++ )
		{
			CFDictionaryRef address = ABMultiValueCopyValueAtIndex(addresses, i);
			NSString *street = [(id)CFDictionaryGetValue(address, kABPersonAddressStreetKey) autorelease];
			NSString *city = [(id)CFDictionaryGetValue(address, kABPersonAddressCityKey) autorelease];
			NSString *state = [(id)CFDictionaryGetValue(address, kABPersonAddressStateKey) autorelease];
			NSString *zip = [(id)CFDictionaryGetValue(address, kABPersonAddressZIPKey) autorelease];
			NSString *country = [(id)CFDictionaryGetValue(address, kABPersonAddressCountryKey) autorelease];
			CFRelease(address);
			
			street = [street stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			city = [city stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			state = [state stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			zip = [zip stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
			country = [country stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];

			NSString *addressstr = [NSString stringWithFormat:@"{ street:'%@', city:'%@', state:'%@', zip:'%@', country:'%@' }, ", 
																street, city, state, zip, country];
			streetAddresses = [streetAddresses stringByAppendingString:addressstr];
		}
		
		streetAddresses = [streetAddresses stringByAppendingString:@"]"];
	}
	
	
	int recordID = ABRecordGetRecordID(recordRef);
	NSString *jsPerson =  [[NSString alloc ]initWithFormat:@"{ id:%d, name:'%@', first:'%@', last:'%@', phones:%@, emails:%@, addresses:%@ }, ",
															recordID, compositeName, firstName, lastName, phoneNumbers, emailAddresses, streetAddresses];
	
	[pool release];
	return jsPerson;
}

- (NSString *)getAllContacts
{
	NSString *jsContacts = @"AppMobi.people = [";
	
	ABAddressBookRef ab = ABAddressBookCreate();
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(ab);
	CFIndex nPeople = CFArrayGetCount(people);
	CFIndex i;
	
	if( [AppMobiDelegate sharedDelegate].isWebContainer == YES && [webView.config.appName compare:@"mobius.app"] == NSOrderedSame )
	{
		// no contacts for anonymous websites
		nPeople = 0;
	}
	
	for (i = 0; i < nPeople; i++) 
	{
		NSString *jsContact = [[self JSONValueForPerson:CFArrayGetValueAtIndex(people, i)] autorelease];
		jsContacts = [jsContacts stringByAppendingString:jsContact];
	}
	
	CFRelease(people);

	jsContacts = [jsContacts stringByAppendingString:@"];"];
	return jsContacts;
}

- (void)getContacts:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSString *jsContacts = [self getAllContacts];
	
	NSString* js = [jsContacts stringByAppendingString:[NSString stringWithString:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.get',true,true);e.success=true;document.dispatchEvent(e);"]];
    AMLog(@"%@", js);
	[webView injectJS:js];
}

- (void)dimissAddModalView:(id)sender 
{
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	
	NSString* js = [NSString stringWithString:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.add',true,true);e.success=false;e.cancelled=true;document.dispatchEvent(e);"];
    AMLog(@"%@", js);
	[webView injectJS:js];
	busy = NO;
}

- (void)addContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	if( busy == YES ) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	
	busy = YES;
	ABNewPersonViewController* newpersonController = [[[ABNewPersonViewController alloc] init] autorelease];
	newpersonController.displayedPerson = ABPersonCreate();
	newpersonController.addressBook = ABAddressBookCreate();
	newpersonController.newPersonViewDelegate = self;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				  target:self action:@selector(dimissAddModalView:)];
	
	newpersonController.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];

	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:newpersonController] autorelease];
	[[AppMobiViewController masterViewController] presentModalViewController:navController animated:YES];
}

- (void)newPersonViewController:(ABNewPersonViewController*)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[newPersonViewController dismissModalViewControllerAnimated:YES];
	
	NSString *jsContacts = [self getAllContacts];
	
	NSString* js = [jsContacts stringByAppendingString:[NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.add',true,true);e.success=true;e.contactid=%d;document.dispatchEvent(e);", ABRecordGetRecordID(person)]];
    AMLog(@"%@", js);
	[webView injectJS:js];
	
	busy = NO;
}

- (void)cancelEditModalView:(id)sender 
{
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.edit',true,true);e.success=false;e.cancelled=true;document.dispatchEvent(e);"];
    AMLog(@"%@", js);
	[webView injectJS:js];
	busy = NO;
	bEditing = NO;
}

- (void)doneEditModalView:(id)sender 
{
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];
	
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.edit',true,true);e.success=true;e.contactid=%d;document.dispatchEvent(e);", editID];
    AMLog(@"%@", js);
	[webView injectJS:js];
	busy = NO;
	bEditing = NO;
}

- (void)editControllerHack:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ABPersonViewController* personController = (ABPersonViewController *)sender;
	while( bEditing == YES )
	{
		[NSThread sleepForTimeInterval:0.25];
		if( personController.navigationItem.leftBarButtonItem != nil )
		{
			UIBarButtonItem *leftp = personController.navigationItem.leftBarButtonItem;
			UIBarButtonItem *rghtp = personController.navigationItem.rightBarButtonItem;
			
			leftp.target = self;
			rghtp.target = self;
			leftp.action = @selector(cancelEditModalView:);
			rghtp.action = @selector(doneEditModalView:);
			bEditing = NO;
		}
	}	
	
	[pool release];
}

- (void)editContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( busy == YES ) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	
	busy = YES;
	bEditing = YES;
	editID = [[arguments objectAtIndex:0] intValue];	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(ab, editID);
	if( recordRef == nil)
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.edit',true,true);e.success=false;e.error='contact not found';e.contactid=%d;document.dispatchEvent(e);", editID];
		AMLog(@"%@",js);
		[webView injectJS:js];
		busy = NO;
		return;
	}
	
	ABPersonViewController* personController = [[[ABPersonViewController alloc] init] autorelease];
	personController.displayedPerson = recordRef;
	personController.addressBook = ab;
	personController.personViewDelegate = self;
	personController.allowsEditing = YES;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:personController] autorelease];
	[[AppMobiViewController masterViewController] presentModalViewController:navController animated:YES];
	
	[personController performSelectorOnMainThread:personController.navigationItem.rightBarButtonItem.action withObject:personController.navigationItem.rightBarButtonItem waitUntilDone:NO];
	[NSThread detachNewThreadSelector:@selector(editControllerHack:) toTarget:self withObject:personController];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					 property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return YES;
}

- (void)chooseContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if( busy == YES ) {
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.busy',true,true);e.success=false;e.message='busy';document.dispatchEvent(e);"];
		AMLog(@"%@",js);
		[webView injectJS:js];
		return;
	}
	
	busy = YES;
	ABPeoplePickerNavigationController* pickerController = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	pickerController.peoplePickerDelegate = self;
	
	[[AppMobiViewController masterViewController] presentModalViewController:pickerController animated:YES];
}

- (void)handleChoose:(ABRecordRef)person
{
	[[AppMobiViewController masterViewController] dismissModalViewControllerAnimated:YES];

	NSString *jsContacts = [self getAllContacts];
	
	NSString* js = [jsContacts stringByAppendingString:[NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.choose',true,true);e.success=true;e.contactid=%d;document.dispatchEvent(e);", ABRecordGetRecordID(person)]];
    AMLog(@"%@", js);
	[webView injectJS:js];
	busy = NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
	     shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self handleChoose:person];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
	     shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	[self handleChoose:person];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[peoplePicker dismissModalViewControllerAnimated:YES];
	NSString* js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.choose',true,true);e.success=false;e.cancelled=true;document.dispatchEvent(e);"];
    AMLog(@"%@", js);
	[webView injectJS:js];
	busy = NO;
}

- (void)removeContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	int recordID = [[arguments objectAtIndex:0] intValue];	

	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(ab, recordID);
	if( recordRef == nil)
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.remove',true,true);e.success=false;e.error='contact not found';e.contactid=%d;document.dispatchEvent(e);", recordID];
		AMLog(@"%@",js);
		[webView injectJS:js];
		busy = NO;
		return;
	}
	
	busy = YES;
	CFErrorRef error;
	BOOL success = ABAddressBookRemoveRecord(ab, recordRef, &error);
	if( success == YES )
		success = ABAddressBookSave(ab, &error);
		
	if( success == YES )
	{
		NSString *jsContacts = [self getAllContacts];
		NSString *js = [jsContacts stringByAppendingFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.remove',true,true);e.success=true;e.contactid=%d;document.dispatchEvent(e);", recordID];
		AMLog(@"%@",js);
		[webView injectJS:js];
	}
	else
	{
		NSString *js = [NSString stringWithFormat:@"var e = document.createEvent('Events');e.initEvent('appMobi.contacts.remove',true,true);e.success=false;e.error='error deleting contact';e.contactid=%d;document.dispatchEvent(e);", recordID];
		AMLog(@"%@",js);
		[webView injectJS:js];
	}
	busy = NO;
}

- (void)dealloc
{
   [super dealloc];
}

@end

