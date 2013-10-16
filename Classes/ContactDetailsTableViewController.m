/* ContactDetailsTableViewController.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */ 

#import "ContactDetailsTableViewController.h"
#import "PhoneMainView.h"
#import "UIEditableTableViewCell.h"
#import "UACellBackgroundView.h"
#import "UILinphone.h"
#import "OrderedDictionary.h"
#import "FastAddressBook.h"
#import "Utils.h"


#import "limitFunctionForDevelopment.h"

#import "ConstantDefinition.h"

#import "LinphoneAppDelegate.h"
@interface Entry : NSObject

@property (assign) ABMultiValueIdentifier identifier;

@end

@implementation Entry

@synthesize identifier;

#pragma mark - Lifecycle Functions

- (id)initWithData:(ABMultiValueIdentifier)aidentifier {
    DebugLog(@"");
    self = [super init];
    if (self != NULL) {
        [self setIdentifier:aidentifier];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end


@implementation ContactDetailsTableViewController

enum _ContactSections {
    ContactSections_None = 0,
    ContactSessions_Message,
    ContactSections_Number,
    ContactSections_Sip,
    ContactSections_Email,
    ContactSections_MAX
};

static const int contactSections[ContactSections_MAX] = {ContactSections_None, ContactSessions_Message, ContactSections_Number, ContactSections_Sip, ContactSections_Email};



@synthesize footerController;
@synthesize headerController;
@synthesize contactDetailsDelegate;
@synthesize contact;
@synthesize userManipulatedData;

#pragma mark - Lifecycle Functions

- (void)initContactDetailsTableViewController {
    DebugLog(@"");
    dataCache = [[NSMutableArray alloc] init];
    labelArray = [[NSMutableArray alloc] initWithObjects:
                  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                  [NSString stringWithString:(NSString*)kABPersonPhoneMobileLabel], 
                  [NSString stringWithString:(NSString*)kABPersonPhoneIPhoneLabel],
                  [NSString stringWithString:(NSString*)kABPersonPhoneMainLabel], nil];
    editingIndexPath = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initContactDetailsTableViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self initContactDetailsTableViewController];
    }
    return self;
}   

- (void)dealloc {
    if(contact != nil && ABRecordGetRecordID(contact) == kABRecordInvalidID) {
        CFRelease(contact);
    }
    if(editingIndexPath != nil) {
        [editingIndexPath release];
    }
    [labelArray release];
    [dataCache release];
    
    [super dealloc];
}


#pragma mark - ViewController Functions

- (NSDictionary *)getReturnValueForTest{
    //For test . server simulation
    
    
    
    NSDictionary * user1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"nguyen mai huy" ?: [NSNull null], @"cn",
                            @"140" ?: [NSNull null], @"departmentNumber",
                            @"114" ?: [NSNull null], @"description",
                            @"140" ?: [NSNull null], @"mobile",
                            @"114" ?: [NSNull null], @"objectclass",
                            @"Tran" ?: [NSNull null], @"sn",
                            @"tnanh" ?: [NSNull null], @"uid",
                            nil];
    
    
    return user1;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [headerController view]; // Force view load
    [footerController view]; // Force view load
    [self appDelegate]._locationRequestDelegate = self;
     
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark -

- (BOOL)isValid {
    return [headerController isValid];
}

- (void)updateModification {
    [contactDetailsDelegate onModification:nil];
}

- (NSMutableArray*)getSectionData:(int)section {
    if(contactSections[section] == ContactSections_Number) {
        return [dataCache objectAtIndex:0];
    } else if(contactSections[section] == ContactSections_Sip) {
        return [dataCache objectAtIndex:1];
    } else if(contactSections[section] == ContactSections_Email) {
        if ([[LinphoneManager instance] lpConfigBoolForKey:@"show_contacts_emails_preference"] == true) {
            return [dataCache objectAtIndex:2];
        } else {
            return nil;
        }
    }
    return nil;
}

+ (NSString*)localizeLabel:(NSString*)str {
    CFStringRef lLocalizedLabel = ABAddressBookCopyLocalizedLabel((CFStringRef) str);
    NSString * retStr = [NSString stringWithString:(NSString*) lLocalizedLabel];
    CFRelease(lLocalizedLabel);
    return retStr;
}

- (NSDictionary*)getLocalizedLabels {
    OrderedDictionary *dict = [[OrderedDictionary alloc] initWithCapacity:[labelArray count]];
    for(NSString *str in labelArray) {
        [dict setObject:[ContactDetailsTableViewController localizeLabel:str] forKey:str];
    }
    return [dict autorelease];
}

- (void)loadData {
    DebugLog(@"");
    [dataCache removeAllObjects];
    
    if(contact == NULL) 
        return;
    
    [LinphoneLogger logc:LinphoneLoggerLog format:"Load data from contact %p", contact];
    // Phone numbers 
    {
        ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        NSMutableArray *subArray = [NSMutableArray array];
        if(lMap) {
            for(int i = 0; i < ABMultiValueGetCount(lMap); ++i) {
                ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(lMap, i);
                Entry *entry = [[Entry alloc] initWithData:identifier];
                [subArray addObject: entry];
                [entry release];
            }
            CFRelease(lMap);
        }
        [dataCache addObject:subArray];
    }
    
    // SIP (IM)
    {
        ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
        NSMutableArray *subArray = [NSMutableArray array];
        if(lMap) {
            for(int i = 0; i < ABMultiValueGetCount(lMap); ++i) {
                ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(lMap, i);
                CFDictionaryRef lDict = ABMultiValueCopyValueAtIndex(lMap, i);
                BOOL add = false;
                if(CFDictionaryContainsKey(lDict, kABPersonInstantMessageServiceKey)) {
                    if(CFStringCompare((CFStringRef)[LinphoneManager instance].contactSipField, CFDictionaryGetValue(lDict, kABPersonInstantMessageServiceKey), kCFCompareCaseInsensitive) == 0) {
                        add = true;
                    }
				} else {						//check domain
					LinphoneAddress* address = linphone_address_new([(NSString*)CFDictionaryGetValue(lDict,kABPersonInstantMessageUsernameKey) UTF8String]);
					if (address) {
						if ([[ContactSelection getSipFilter] compare:@"*" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
							add = true;
						} else {
							NSString* domain = [NSString stringWithCString:linphone_address_get_domain(address)
																  encoding:[NSString defaultCStringEncoding]];
							add = [domain compare:[ContactSelection getSipFilter] options:NSCaseInsensitiveSearch] == NSOrderedSame;
						}
						linphone_address_destroy(address);
					} else {
						add = false;
					}
				}
				if(add) {
					Entry *entry = [[Entry alloc] initWithData:identifier];
					[subArray addObject: entry];
					[entry release];
				}
				CFRelease(lDict);
			}
            CFRelease(lMap);
        }
        [dataCache addObject:subArray];
    }
    
    // Email
    if ([[LinphoneManager instance] lpConfigBoolForKey:@"show_contacts_emails_preference"] == true)
    {
        ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
        NSMutableArray *subArray = [NSMutableArray array];
        if(lMap) {
            for(int i = 0; i < ABMultiValueGetCount(lMap); ++i) {
                ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(lMap, i);
                CFDictionaryRef lDict = ABMultiValueCopyValueAtIndex(lMap, i);
                Entry *entry = [[Entry alloc] initWithData:identifier];
                [subArray addObject: entry];
                [entry release];
                CFRelease(lDict);
            }
            CFRelease(lMap);
        }
        [dataCache addObject:subArray];
    }

    if(contactDetailsDelegate != nil) {
        [contactDetailsDelegate onModification:nil];
    }
    [self.tableView reloadData];
}

-(Entry *) setOrCreateSipContactEntry:(Entry *)entry withValue:(NSString*)value {
    DebugLog(@"");
	ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
	ABMutableMultiValueRef lMap;
	if(lcMap != NULL) {
		lMap = ABMultiValueCreateMutableCopy(lcMap);
		CFRelease(lcMap);
	} else {
		lMap = ABMultiValueCreateMutable(kABStringPropertyType);
	}
	ABMultiValueIdentifier index;
	NSError* error = NULL;
	
	CFStringRef keys[] = { kABPersonInstantMessageUsernameKey,  kABPersonInstantMessageServiceKey};
	CFTypeRef values[] = { [value copy], [LinphoneManager instance].contactSipField };
	CFDictionaryRef lDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 2, NULL, NULL);
	if (entry) {
		index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
		ABMultiValueReplaceValueAtIndex(lMap, lDict, index);
	} else {
		
		CFStringRef label = (CFStringRef)[labelArray objectAtIndex:0];
		ABMultiValueAddValueAndLabel(lMap, lDict, label, &index);
	}
	if (!ABRecordSetValue(contact, kABPersonInstantMessageProperty, lMap, (CFErrorRef*)&error)) {
		[LinphoneLogger log:LinphoneLoggerLog format:@"Can't set contact with value [%@] cause [%@]", value,[error localizedDescription]];
	} else {
		if (entry == nil) {
			entry = [[Entry alloc] initWithData:index];
		}
		CFRelease(lDict);
		/*check if message type is kept or not*/
		lcMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
		lMap = ABMultiValueCreateMutableCopy(lcMap);
		CFRelease(lcMap);
		index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
		lDict = ABMultiValueCopyValueAtIndex(lMap,index);
		if(!CFDictionaryContainsKey(lDict, kABPersonInstantMessageServiceKey)) {
			/*too bad probably a gtalk number, storing uri*/
			NSString* username = CFDictionaryGetValue(lDict, kABPersonInstantMessageUsernameKey);
			LinphoneAddress* address = linphone_core_interpret_url([LinphoneManager getLc]
																   ,[username UTF8String]);
			char* uri = linphone_address_as_string_uri_only(address);
			CFStringRef keys[] = { kABPersonInstantMessageUsernameKey,  kABPersonInstantMessageServiceKey};
			CFTypeRef values[] = { [NSString stringWithCString:uri encoding:[NSString defaultCStringEncoding]], [LinphoneManager instance].contactSipField };
			CFDictionaryRef lDict2 = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 2, NULL, NULL);
			ABMultiValueReplaceValueAtIndex(lMap, lDict2, index);
			if (!ABRecordSetValue(contact, kABPersonInstantMessageProperty, lMap, (CFErrorRef*)&error)) {
				[LinphoneLogger log:LinphoneLoggerLog format:@"Can't set contact with value [%@] cause [%@]", value,[error localizedDescription]];
			}
			CFRelease(lDict2);
			linphone_address_destroy(address);
			ms_free(uri);
		}
		CFRelease(lMap);
	}
	CFRelease(lDict);
	
	return entry;
}
-(void) setSipContactEntry:(Entry *)entry withValue:(NSString*)value {
	[self setOrCreateSipContactEntry:entry withValue:value];
}
- (void)addEntry:(UITableView*)tableview section:(NSInteger)section animated:(BOOL)animated {
    [self addEntry:tableview section:section animated:animated value:@""];
}

- (void)addEntry:(UITableView*)tableview section:(NSInteger)section animated:(BOOL)animated value:(NSString *)value{
    NSMutableArray *sectionArray = [self getSectionData:section];
    NSUInteger count = [sectionArray count];
    NSError* error = NULL;
    bool added = TRUE;
    if(contactSections[section] == ContactSections_Number) {
        ABMultiValueIdentifier identifier;
        ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        ABMutableMultiValueRef lMap;
        if(lcMap != NULL) {
            lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
        } else {
            lMap = ABMultiValueCreateMutable(kABStringPropertyType);
        }
        CFStringRef label = (CFStringRef)[labelArray objectAtIndex:0];
        if(!ABMultiValueAddValueAndLabel(lMap, [value copy], label, &identifier)) {
            added = false;
        }
        
        if(added  && ABRecordSetValue(contact, kABPersonPhoneProperty, lMap, (CFErrorRef*)&error)) {
            Entry *entry = [[Entry alloc] initWithData:identifier];
            [sectionArray addObject:entry];
            [entry release];
        } else {
            added = false;
            [LinphoneLogger log:LinphoneLoggerLog format:@"Can't add entry: %@", [error localizedDescription]];
        }
        CFRelease(lMap);
    } else if(contactSections[section] == ContactSections_Sip) {
        Entry *entry = [self setOrCreateSipContactEntry:nil withValue:value];
        if (entry) {
			[sectionArray addObject:entry];
			[entry release];
			added=true;
		} else {
			added=false;
			[LinphoneLogger log:LinphoneLoggerError format:@"Can't add entry for value: %@", value];
		}
    } else if(contactSections[section] == ContactSections_Email) {
        ABMultiValueIdentifier identifier;
        ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
        ABMutableMultiValueRef lMap;
        if(lcMap != NULL) {
            lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
        } else {
            lMap = ABMultiValueCreateMutable(kABStringPropertyType);
        }
        CFStringRef label = (CFStringRef)[labelArray objectAtIndex:0];
        if(!ABMultiValueAddValueAndLabel(lMap, [value copy], label, &identifier)) {
            added = false;
        }
        
        if(added  && ABRecordSetValue(contact, kABPersonEmailProperty, lMap, (CFErrorRef*)&error)) {
            Entry *entry = [[Entry alloc] initWithData:identifier];
            [sectionArray addObject:entry];
            [entry release];
        } else {
            added = false;
            [LinphoneLogger log:LinphoneLoggerLog format:@"Can't add entry: %@", [error localizedDescription]];
        }
        CFRelease(lMap);
    }
    
    if (added && animated) {
        // Update accessory
        if (count > 0) {
            [tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:count -1 inSection:section]] withRowAnimation:FALSE];
        }
        [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    if(contactDetailsDelegate != nil) {
        [contactDetailsDelegate onModification:nil];
    }
}

- (void)removeEmptyEntry:(UITableView*)tableview section:(NSInteger)section animated:(BOOL)animated {
    NSMutableArray *sectionDict = [self getSectionData:section];
    int row = [sectionDict count] - 1;
    if(row >= 0) {
        Entry *entry = [sectionDict objectAtIndex:row];
        if(contactSections[section] == ContactSections_Number) {
            ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            CFStringRef valueRef = ABMultiValueCopyValueAtIndex(lMap, index);
            if(![(NSString*) valueRef length]) {
                [self removeEntry:tableview path:[NSIndexPath indexPathForRow:row inSection:section] animated:animated];
            }
            CFRelease(valueRef);
            CFRelease(lMap);
        } else if(contactSections[section] == ContactSections_Sip) {
            ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            CFDictionaryRef lDict = ABMultiValueCopyValueAtIndex(lMap, index);
            CFStringRef valueRef = CFDictionaryGetValue(lDict, kABPersonInstantMessageUsernameKey);
            if(![(NSString*) valueRef length]) {
                [self removeEntry:tableview path:[NSIndexPath indexPathForRow:row inSection:section] animated:animated];
            }
            CFRelease(lDict);
            CFRelease(lMap);
        } else if(contactSections[section] == ContactSections_Email) {
            ABMultiValueRef lMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            CFStringRef valueRef = ABMultiValueCopyValueAtIndex(lMap, index);
            if(![(NSString*) valueRef length]) {
                [self removeEntry:tableview path:[NSIndexPath indexPathForRow:row inSection:section] animated:animated];
            }
            CFRelease(valueRef);
            CFRelease(lMap);
        }
    }
    if(contactDetailsDelegate != nil) {
        [contactDetailsDelegate onModification:nil];
    }
}

- (void)removeEntry:(UITableView*)tableview path:(NSIndexPath*)indexPath animated:(BOOL)animated {
    NSMutableArray *sectionArray = [self getSectionData:[indexPath section]];
    Entry *entry = [sectionArray objectAtIndex:[indexPath row]];
    if(contactSections[[indexPath section]] == ContactSections_Number) {
        ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
        CFRelease(lcMap);
        int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
        ABMultiValueRemoveValueAndLabelAtIndex(lMap, index);
        ABRecordSetValue(contact, kABPersonPhoneProperty, lMap, nil);
        CFRelease(lMap);
    } else if(contactSections[[indexPath section]] == ContactSections_Sip) {
        ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
        ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
        CFRelease(lcMap);
        int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
        ABMultiValueRemoveValueAndLabelAtIndex(lMap, index);
        ABRecordSetValue(contact, kABPersonInstantMessageProperty, lMap, nil);
        CFRelease(lMap);
    } else if(contactSections[[indexPath section]] == ContactSections_Email) {
        ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
        ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
        CFRelease(lcMap);
        int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
        ABMultiValueRemoveValueAndLabelAtIndex(lMap, index);
        ABRecordSetValue(contact, kABPersonEmailProperty, lMap, nil);
        CFRelease(lMap);
    }
    [sectionArray removeObjectAtIndex:[indexPath row]];
    
    NSArray *tagInsertIndexPath = [NSArray arrayWithObject:indexPath];
    if (animated) {
        [tableview deleteRowsAtIndexPaths:tagInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Property Functions

- (void)setContact:(ABRecordRef)acontact {
    if(contact != nil && ABRecordGetRecordID(contact) == kABRecordInvalidID) {
        CFRelease(contact);
    }
    contact = acontact;
    [self loadData];
    [headerController setContact:contact];
}

- (void)addSipField:(NSString*)address {
    int i = 0;
    while(i < ContactSections_MAX && contactSections[i] != ContactSections_Sip) ++i;
    [self addEntry:[self tableView] section:i animated:FALSE value:address];
}

- (void)addEmailField:(NSString*)address {
    int i = 0;
    while(i < ContactSections_MAX && contactSections[i] != ContactSections_Email) ++i;
    [self addEntry:[self tableView] section:i animated:FALSE value:address];
}


#pragma mark - UITableViewDataSource Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [[self getSectionData:section] count];


    if (section == 0) {
        return 2;
    } else {
        return 1;
    } 

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {

    static NSString *kCellId = @"ContactDetailsCell";
    DebugLog(@" user data = %@", self.userManipulatedData);
    

    
    headerController.contactName.text = self.userManipulatedData[@"cn"][@"name"];
    UIEditableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[[UIEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kCellId] autorelease];
        [cell.detailTextField setDelegate:self];
        [cell.detailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [cell.detailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        // Background View
        UACellBackgroundView *selectedBackgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView setBackgroundColor:LINPHONE_TABLE_CELL_BACKGROUND_COLOR];
    }
//    NSDictionary *dict = [self.userManipulatedData objectAtIndex:indexPath.section ];
 //   InfoLog(@"dict = %@",dict);
    
    
    if (indexPath.section == 0) {
        NSArray *nameArray = self.userManipulatedData[@"Phone"] ;
        
        InfoLog(@"nameArray = %@", nameArray);
        
        NSDictionary *dic_info = [nameArray objectAtIndex:indexPath.row];
        InfoLog(@"dic_info = %@ with row %d", dic_info,indexPath.row  );
        NSString * data;
        
        for(id key in dic_info){
            data = [dic_info objectForKey:key];
            
            [cell.textLabel setText:key];
            [cell.detailTextLabel setText:data];
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"Send a message";
        
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = [self.userManipulatedData[@"email"] lastObject][@"mail"];
        
    } else if (indexPath.section == 3) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @" Hoan kiem , Ha Noi, Viet Name ";
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"index path  = %d", indexPath.section);
    DebugLog(@" user data = %@", self.userManipulatedData);


    if (![limitFunctionForDevelopment limitUserClickableButton:indexPath]) {
        return;
    }
    
    NSArray * phoneInfo = self.userManipulatedData[@"Phone"];


    NSString *mobilePhoneInfo = [phoneInfo objectAtIndex:indexPath.row][@"mobile"];

    NSString *dest=NULL;;
    dest = [FastAddressBook normalizeSipURI:[NSString stringWithString:(NSString*) mobilePhoneInfo]];
    DebugLog(@"dest = %@", [dest description]  );
    if(dest != nil) {
        NSString *displayName = [FastAddressBook getContactDisplayName:contact];
        
        /*
        if([ContactSelection getSelectionMode] != ContactSelectionModeMessage) {
            // Go to dialer view
            DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
            if(controller != nil) {
                [controller call:dest displayName:displayName];
            }
        } else {
            // Go to Chat room view
            [[PhoneMainView instance] popToView:[ChatViewController compositeViewDescription]]; // Got to Chat and push ChatRoom
            ChatRoomViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE], ChatRoomViewController);
            if(controller != nil) {
                [controller setRemoteAddress:dest];
            }
        }*/
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            // Go to dialer view
            DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
            if(controller != nil) {
                [controller call:dest displayName:displayName];
            }
        } else if (indexPath.section == 1){
            // Go to Chat room view
            [[PhoneMainView instance] popToView:[ChatViewController compositeViewDescription]]; // Got to Chat and push ChatRoom
            ChatRoomViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE], ChatRoomViewController);
            if(controller != nil) {
                [controller setRemoteAddress:dest];
            }
        }
    }
   }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath  {
    [LinphoneUtils findAndResignFirstResponder:[self tableView]];
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [tableView beginUpdates];
        [self addEntry:tableView section:[indexPath section] animated:TRUE];
        [tableView  endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self removeEntry:tableView path:indexPath animated:TRUE];
        [tableView  endUpdates];
    }
}

#pragma mark - UITableViewDelegate Functions


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    bool_t showEmails = [[LinphoneManager instance] lpConfigBoolForKey:@"show_contacts_emails_preference"];
    // Resign keyboard
    if(!editing) {
        [LinphoneUtils findAndResignFirstResponder:[self tableView]];
    }

    [headerController setEditing:editing animated:animated];
    [footerController setEditing:editing animated:animated];
    
    if(animated) {
        [self.tableView beginUpdates];
    }
    if(editing) {
        for (int section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; ++section) {
            if(contactSections[section] == ContactSections_Number ||
               contactSections[section] == ContactSections_Sip ||
               (showEmails && contactSections[section] == ContactSections_Email))
            [self addEntry:self.tableView section:section animated:animated];
        }
    } else {
        for (int section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; ++section) {
            if(contactSections[section] == ContactSections_Number ||
               contactSections[section] == ContactSections_Sip ||
               (showEmails && contactSections[section] == ContactSections_Email))
            [self removeEmptyEntry:self.tableView section:section animated:animated];
        }
    }
    if(animated) {
        [self.tableView endUpdates];
    }
    
    [super setEditing:editing animated:animated];
    if(contactDetailsDelegate != nil) {
        [contactDetailsDelegate onModification:nil];
    }
}
/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int last_index = [[self getSectionData:[indexPath section]] count] - 1;
    if (indexPath.row == last_index) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {   
    if(section == ContactSections_None) {
        return [headerController view];
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {   
    if(section == (ContactSections_MAX - 1)) {
        if(ABRecordGetRecordID(contact) != kABRecordInvalidID) {
            return [footerController view];
        }
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (contactSections[section] == ContactSections_None){
        return NSLocalizedString(@"Employee numbers", nil);
    }else if (contactSections[section] == ContactSessions_Message) {
        return NSLocalizedString(@"Message", nil);
    }else if (contactSections[section] == ContactSections_Number) {
        return NSLocalizedString(@"Email", nil);
    } else if(contactSections[section] == ContactSections_Sip) {
        return NSLocalizedString(@"Location", nil);
    } else if(contactSections[section] == ContactSections_Email) {
        return NSLocalizedString(@"Email addresses", nil);
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if(section == ContactSections_None) {
        return [UIContactDetailsHeader height:[headerController isEditing]];
    } else {
        // Hide section if nothing in it
        /*
        if([[self getSectionData:section] count] > 0)
            return 22;
        else 
            return 0.000001f; // Hack UITableView = 0
         */
        return 22;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == (ContactSections_MAX - 1)) {
        if(ABRecordGetRecordID(contact) != kABRecordInvalidID) {
            return [UIContactDetailsFooter height:[footerController isEditing]];
        } else {
            return 0.000001f; // Hack UITableView = 0
        }
    } else if(section == ContactSections_None) {
        return 0.000001f; // Hack UITableView = 0
    }
    return 10.0f;
}


#pragma mark - ContactDetailsLabelDelegate Functions

- (void)changeContactDetailsLabel:(NSString *)value {
    if(value != nil) {
        NSMutableArray *sectionDict = [self getSectionData:[editingIndexPath section]];
        Entry *entry = [sectionDict objectAtIndex:[editingIndexPath row]];
        if(contactSections[[editingIndexPath section]] == ContactSections_Number) {
            ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
            ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            ABMultiValueReplaceLabelAtIndex(lMap, (CFStringRef)(value), index);
            ABRecordSetValue(contact, kABPersonPhoneProperty, lMap, nil);
            CFRelease(lMap);
        } else if(contactSections[[editingIndexPath section]] == ContactSections_Sip) {
            ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
            ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            ABMultiValueReplaceLabelAtIndex(lMap, (CFStringRef)(value), index);
            ABRecordSetValue(contact, kABPersonInstantMessageProperty, lMap, nil);
            CFRelease(lMap);
        } else if(contactSections[[editingIndexPath section]] == ContactSections_Email) {
            ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
            ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            ABMultiValueReplaceLabelAtIndex(lMap, (CFStringRef)(value), index);
            ABRecordSetValue(contact, kABPersonEmailProperty, lMap, nil);
            CFRelease(lMap);
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: editingIndexPath] withRowAnimation:FALSE];
        [self.tableView endUpdates];
    }
    [editingIndexPath release];
    editingIndexPath = nil;
}


#pragma mark - UITextFieldDelegate Functions

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(contactDetailsDelegate != nil) {
        [self performSelector:@selector(updateModification) withObject:nil afterDelay:0];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UIView *view = [textField superview]; 
    // Find TableViewCell
    if(view != nil && ![view isKindOfClass:[UIEditableTableViewCell class]]) view = [view superview];
    if(view != nil) {
        UIEditableTableViewCell *cell = (UIEditableTableViewCell*)view;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        NSMutableArray *sectionDict = [self getSectionData:[path section]];
        Entry *entry = [sectionDict objectAtIndex:[path row]];
        NSString *value = [textField text];
        if(contactSections[[path section]] == ContactSections_Number) {
            ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonPhoneProperty);
            ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            ABMultiValueReplaceValueAtIndex(lMap, (CFStringRef)value, index);
            ABRecordSetValue(contact, kABPersonPhoneProperty, lMap, nil);
            CFRelease(lMap);
        } else if(contactSections[[path section]] == ContactSections_Sip) {
            [self setSipContactEntry:entry withValue:value];
        } else if(contactSections[[path section]] == ContactSections_Email) {
            ABMultiValueRef lcMap = ABRecordCopyValue(contact, kABPersonEmailProperty);
            ABMutableMultiValueRef lMap = ABMultiValueCreateMutableCopy(lcMap);
            CFRelease(lcMap);
            int index = ABMultiValueGetIndexForIdentifier(lMap, [entry identifier]);
            ABMultiValueReplaceValueAtIndex(lMap, (CFStringRef)value, index);
            ABRecordSetValue(contact, kABPersonEmailProperty, lMap, nil);
            CFRelease(lMap);
        }
        [cell.detailTextLabel setText:value];
    } else {
        [LinphoneLogger logc:LinphoneLoggerError format:"Not valid UIEditableTableViewCell"];
    }
    if(contactDetailsDelegate != nil) {
        [self performSelector:@selector(updateModification) withObject:nil afterDelay:0];
    }
    return TRUE;
}

#pragma mark - Location request
@synthesize xmppStream;

- (LinphoneAppDelegate *)appDelegate {
	return (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
	return [[self appDelegate] xmppStream];
}

-(void) locationRequest{
    NSString *messageStr = @"position|get|";
    // NSString *userID = [self.userManipulatedData[@"userID"] lastObject];
    // NSString *messageStr = [@"position|get|" stringByAppendingString:userID];

    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:@"ninhnb@localhost"]];
    [msg addBody:messageStr];
    [self.xmppStream sendElement: msg];
    NSLog(@"Message sent \n\n");
}
@end
