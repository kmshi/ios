
#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppMobiCommand.h"

@interface AppMobiContacts : AppMobiCommand <ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate> 
{
	int editID;
	BOOL bEditing;
	BOOL busy;
}

- (void)getContacts:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)addContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)editContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)removeContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)chooseContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person;

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue;

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;

@end