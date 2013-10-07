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
#import "ConvertionHandler.h"

#import "ldapTest.h"




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



- (void)loadData{
    InfoLog(@"");

    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        self.dataArray = get_data_from_server(NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];     
        });
        
    });
}

 
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

    NSString *cellValue = [ConvertionHandler returnUserRecord:dataArray atIndexPath:indexPath][@"cn"];
    DebugLog(@"cellValue = %@", cellValue);
    
    cell.firstNameLabel.text = cellValue;
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
    DebugLog(@"flag linphone_address = %d", LINPHONE_ADDRESS);
    ContactDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactDetailsViewController compositeViewDescription] push:TRUE], ContactDetailsViewController);
    if(controller != nil) {
        DebugLog(@"");
        
        // set value for ContactDetailViewController accordingly
        NSDictionary *userRecord = [ConvertionHandler returnUserRecord:dataArray atIndexPath:indexPath];
        controller.userRecord = userRecord;
        DebugLog(@"user record = %@", controller.userRecord);

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
