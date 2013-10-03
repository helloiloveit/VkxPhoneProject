/* ContactsTableViewController.m
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

#import "ContactsTableViewController.h"
#import "UIContactCell.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "UACellBackgroundView.h"
#import "UILinphone.h"
#import "Utils.h"
#import "ConstantDefinition.h"

#import "ldapTest.h"

#define LINPHONE_ADDRESS 0

@implementation ContactsTableViewController

static void sync_address_book (ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
@synthesize dataArray;

#pragma mark - Lifecycle Functions

- (void)initContactsTableViewController {
    addressBookMap  = [[OrderedDictionary alloc] init];
    avatarMap = [[NSMutableDictionary alloc] init];
    
    addressBook = ABAddressBookCreate();
	
    ABAddressBookRegisterExternalChangeCallback(addressBook, sync_address_book, self);
}

- (id)init {
    self = [super init];
    if (self) {
		[self initContactsTableViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
		[self initContactsTableViewController];
	}
    return self;
}	

- (void)dealloc {
    ABAddressBookUnregisterExternalChangeCallback(addressBook, sync_address_book, self);
    CFRelease(addressBook);
    [addressBookMap release];
    [avatarMap release];
    [super dealloc];
}


#pragma mark - 
- (NSArray *)getArrayValue{
    //For test . server simulation
    
    
    
    NSDictionary * user1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"Tran Ngoc Anh" ?: [NSNull null], @"cn",
                             @"uid=tnanh,ou=rd,ou=Users,dc=example,dc=com" ?: [NSNull null], @"dn",
                            @"123123" ?: [NSNull null], @"uid",
                            nil];
    NSDictionary * user2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"Pham Thi Thu Hien" ?: [NSNull null], @"cn",
                            @"uid=tnanh,ou=rd,ou=Users,dc=example,dc=com" ?: [NSNull null], @"dn",
                            @"thuhien3969" ?: [NSNull null], @"uid",
                            nil];

    
    
    
    NSArray  * myArray1 = [NSArray arrayWithObjects:user1, user2,  nil];
    NSArray  * myArray2 = [NSArray arrayWithObjects:user1, user2,  nil];
    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           myArray1 ?: [NSNull null], @"R&D",
                           nil];
    
    NSDictionary * dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                            myArray2 ?: [NSNull null], @"R&D2",
                            nil];

    NSArray  * myArray3 = [NSArray arrayWithObjects:dict, dict2, nil];
    return myArray3;
}
#ifdef LINPHONE_ADDRESS
- (void)loadData{
    DebugLog(@"");
    self.dataArray = get_data_from_server(NULL);
    //self.dataArray = [self getArrayValue];
     DebugLog(@"dataArray = %@", self.dataArray);
    [self.tableView reloadData];
}
#else
- (void)loadData {
    [LinphoneLogger logc:LinphoneLoggerLog format:"Load contact list"];
    @synchronized (addressBookMap) {
        
        // Reset Address book
        [addressBookMap removeAllObjects];
        
        NSArray *lContacts = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (id lPerson in lContacts) {
            BOOL add = true;
            if([ContactSelection getSipFilter] || [ContactSelection getEmailFilter]) {
                add = false;
            }
            if([ContactSelection getSipFilter]) {
                ABMultiValueRef lMap = ABRecordCopyValue((ABRecordRef)lPerson, kABPersonInstantMessageProperty);
                for(int i = 0; i < ABMultiValueGetCount(lMap); ++i) {
                    CFDictionaryRef lDict = ABMultiValueCopyValueAtIndex(lMap, i);
                    if(CFDictionaryContainsKey(lDict, kABPersonInstantMessageServiceKey)) {
                        CFStringRef serviceKey = CFDictionaryGetValue(lDict, kABPersonInstantMessageServiceKey);
						CFStringRef username = username=CFDictionaryGetValue(lDict, kABPersonInstantMessageUsernameKey);
                        if(CFStringCompare((CFStringRef)[LinphoneManager instance].contactSipField, serviceKey, kCFCompareCaseInsensitive) == 0) {
                            add = true;
                        }  else {
							add=false;
						}
                    }  else {
						//check domain
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
                    CFRelease(lDict);
                }
            }
            if ((add == false) && [ContactSelection getEmailFilter]) {
                ABMultiValueRef lMap = ABRecordCopyValue((ABRecordRef)lPerson, kABPersonEmailProperty);
                if (ABMultiValueGetCount(lMap) > 0) {
                    add = true;
                }
            }
            if(add) {
                CFStringRef lFirstName = ABRecordCopyValue((ABRecordRef)lPerson, kABPersonFirstNameProperty);
                CFStringRef lLocalizedFirstName = (lFirstName != nil)? ABAddressBookCopyLocalizedLabel(lFirstName): nil;
                CFStringRef lLastName = ABRecordCopyValue((ABRecordRef)lPerson, kABPersonLastNameProperty);
                CFStringRef lLocalizedLastName = (lLastName != nil)? ABAddressBookCopyLocalizedLabel(lLastName): nil;
                CFStringRef lOrganization = ABRecordCopyValue((ABRecordRef)lPerson, kABPersonOrganizationProperty);
                CFStringRef lLocalizedlOrganization = (lOrganization != nil)? ABAddressBookCopyLocalizedLabel(lOrganization): nil;
                NSString *name = nil;
                if(lLocalizedFirstName != nil && lLocalizedLastName != nil) {
                    name=[NSString stringWithFormat:@"%@%@", [(NSString *)lLocalizedFirstName retain], [(NSString *)lLocalizedLastName retain]];
                } else if(lLocalizedLastName != nil) {
                    name=[NSString stringWithFormat:@"%@",[(NSString *)lLocalizedLastName retain]];
                } else if(lLocalizedFirstName != nil) {
                    name=[NSString stringWithFormat:@"%@",[(NSString *)lLocalizedFirstName retain]];
                } else if(lLocalizedlOrganization != nil) {
                    name=[NSString stringWithFormat:@"%@",[(NSString *)lLocalizedlOrganization retain]];
                }
                if(name != nil && [name length] > 0) {
                    // Put in correct subDic
                    NSString *firstChar = [[name substringToIndex:1] uppercaseString];
                    if([firstChar characterAtIndex:0] < 'A' || [firstChar characterAtIndex:0] > 'Z') {
                        firstChar = @"#";
                    }
                    OrderedDictionary *subDic =[addressBookMap objectForKey: firstChar];
                    if(subDic == nil) {
                        subDic = [[[OrderedDictionary alloc] init] autorelease];
                        [addressBookMap insertObject:subDic forKey:firstChar selector:@selector(caseInsensitiveCompare:)];
                    }
                    [subDic insertObject:lPerson forKey:name selector:@selector(caseInsensitiveCompare:)];
                }
                if(lLocalizedlOrganization != nil)
                    CFRelease(lLocalizedlOrganization);
                if(lOrganization != nil)
                    CFRelease(lOrganization);
                if(lLocalizedLastName != nil)
                    CFRelease(lLocalizedLastName);
                if(lLastName != nil)
                    CFRelease(lLastName);
                if(lLocalizedFirstName != nil)
                    CFRelease(lLocalizedFirstName);
                if(lFirstName != nil)
                    CFRelease(lFirstName);
            }
        }
        if (lContacts) CFRelease(lContacts);
    }
    [self.tableView reloadData];
}

#endif
 
static void sync_address_book (ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    ContactsTableViewController* controller = (ContactsTableViewController*)context;
    ABAddressBookRevert(addressBook);
    [controller->avatarMap removeAllObjects];
    [controller loadData];
}

#pragma mark - ViewController Functions

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDataSource Functions

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [addressBookMap allKeys];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    InfoLog(@"");
    DebugLog(@"count = %d", [dataArray count]);
    return [dataArray count];
}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [addressBookMap count];
}
*/


#ifdef LINPHONE_ADDRESS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    InfoLog(@"");
    
    //Number of rows it should expect should be based on the section
    /*
     NSDictionary *dictionary = [dataArray objectAtIndex:section];
     NSArray *array = [dictionary objectForKey:@"data"];
     */
    
    NSDictionary *dict = [dataArray objectAtIndex:section ];
    NSArray *nameArray;
    DebugLog(@"dict = %@", dict);
    for (id key in dict)
        nameArray = [dict objectForKey:key];
    DebugLog(@"nameArray  count = %D",[nameArray count]);
    

    return [nameArray count];
}

#else
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(OrderedDictionary *)[addressBookMap objectForKey: [addressBookMap keyAtIndex: section]] count];

}
#endif
#ifdef LINPHONE_ADDRESS

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"Ldap");
    static NSString *kCellId = @"UIContactCell";
    UIContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        DebugLog(@"cell = nil");
        cell = [[[UIContactCell alloc] initWithIdentifier:kCellId] autorelease];
        
        // Background View
        UACellBackgroundView *selectedBackgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView setBackgroundColor:LINPHONE_TABLE_CELL_BACKGROUND_COLOR];
        DebugLog(@"l2");
    }

  //  DebugLog(@"dataArray = %@", [dataArray description]);
    DebugLog(@"indexpath section %d", indexPath.section);
    DebugLog(@"l3");
    
    DebugLog(@"dataArray = %@", [self.dataArray description]);
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.section ];
    InfoLog(@"dict = %@",[dict description]);
    NSArray *nameArray;
    for (id key in dict)
    {
        nameArray = [dict objectForKey:key];
        //InfoLog(@"nameArray = %@", nameArray);
        //  NSString *cellValue = [nameArray objectAtIndex:indexPath.row];
    }
    //InfoLog(@"nameArray = %@", nameArray);
    
    
    NSString *cellValue = [nameArray objectAtIndex:indexPath.row][@"cn"];
    
    DebugLog(@"cellValue = %@", cellValue);
    
   cell.firstNameLabel.text = cellValue;
   // cell.firstNameLabel.text = @"lllaa";
    cell.lastNameLabel.text = nil;
    cell.avatarImage.image = [UIImage imageNamed:@"avatar.png"];
   // [cell setDataArray: dataArray];
    return cell;
}
#else
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"");
    static NSString *kCellId = @"UIContactCell";   
    UIContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[[UIContactCell alloc] initWithIdentifier:kCellId] autorelease];
        
        // Background View
        UACellBackgroundView *selectedBackgroundView = [[[UACellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView setBackgroundColor:LINPHONE_TABLE_CELL_BACKGROUND_COLOR];
    }
    OrderedDictionary *subDic = [addressBookMap objectForKey: [addressBookMap keyAtIndex: [indexPath section]]]; 
    
    NSString *key = [[subDic allKeys] objectAtIndex:[indexPath row]];
    ABRecordRef contact = [subDic objectForKey:key];
    
    // Cached avatar
    UIImage *image = nil;
    id data = [avatarMap objectForKey:[NSNumber numberWithInt: ABRecordGetRecordID(contact)]];
    if(data == nil) {
        image = [FastAddressBook getContactImage:contact thumbnail:true];
        if(image != nil) {
            [avatarMap setObject:image forKey:[NSNumber numberWithInt: ABRecordGetRecordID(contact)]];
        } else {
            [avatarMap setObject:[NSNull null] forKey:[NSNumber numberWithInt: ABRecordGetRecordID(contact)]];
        }
    } else if(data != [NSNull null]) {
        image = data;
    }
    if(image == nil) {
        image = [UIImage imageNamed:@"avatar_unknown_small.png"];
    }
    [[cell avatarImage] setImage:image];
    DebugLog(@"");
    [cell setContact: contact];
    return cell;
}

#endif
#ifdef LINPHONE_ADDRESS
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = [dataArray objectAtIndex:section ];
    NSString *tabInfo;
    for (id key in dict)
        tabInfo = key;
    return tabInfo;
    
}
#else
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [addressBookMap keyAtIndex: section];
}
#endif
#ifdef LINPHONE_ADDRESS
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Go to Contact details view
    ContactDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactDetailsViewController compositeViewDescription] push:TRUE], ContactDetailsViewController);
    if(controller != nil) {
        DebugLog(@"");
        /*
        if([ContactSelection getSelectionMode] != ContactSelectionModeEdit) {
            [controller setContact:lPerson];
        } else {
            [controller editContact:lPerson address:[ContactSelection getAddAddress]];
        }
         */
    }
    
}
#else
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderedDictionary *subDic = [addressBookMap objectForKey: [addressBookMap keyAtIndex: [indexPath section]]]; 
    ABRecordRef lPerson = [subDic objectForKey: [subDic keyAtIndex:[indexPath row]]];
    
    // Go to Contact details view
    ContactDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactDetailsViewController compositeViewDescription] push:TRUE], ContactDetailsViewController);
    if(controller != nil) {
        if([ContactSelection getSelectionMode] != ContactSelectionModeEdit) {
            [controller setContact:lPerson];
        } else {
            [controller editContact:lPerson address:[ContactSelection getAddAddress]];
        }
    }
}
#endif

#pragma mark - UITableViewDelegate Functions

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

@end
