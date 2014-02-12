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

#import "ContactInfoHandler.h"


@implementation ContactsTableViewController

static void sync_address_book (ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
@synthesize dataArray;
@synthesize searchBar;

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

-(void) viewDidLoad{
    [super viewDidLoad];
    onlineBuddies = [[NSMutableArray alloc] init];
    searchResult = [[NSMutableArray alloc] init];
    [self appDelegate]._contactDelegate = self;
    [self appDelegate]._chatDelegate = self;
}

- (void)dealloc {
    ABAddressBookUnregisterExternalChangeCallback(addressBook, sync_address_book, self);
    CFRelease(addressBook);
    [addressBookMap release];
    [avatarMap release];
    [searchBar release];
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
    InfoLog(@"%hhd", hasContactList);
 //   if (!hasContactList){
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        @try {
            self.dataArray = get_data_from_server(NULL);
   //         hasContactList = YES;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            [alertHandler contactListError];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];
        });
        
    });
    
 //   }
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResult count];
    }else
    {
        return [dataArray count];
    }
}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [addressBookMap count];
}
*/


#ifdef LINPHONE_ADDRESS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    InfoLog(@"");
    NSDictionary *dict;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        dict = [searchResult objectAtIndex:section];
    }
    else
    {
    //NSDictionary
        dict = [dataArray objectAtIndex:section ];
    }
    NSArray *nameArray;
  //  DebugLog(@"dict = %@", dict);
    for (id key in dict)

        nameArray = [dict objectForKey:key];
  //  DebugLog(@"nameArray  count = %D",[nameArray count]);
    

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

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSString *name = [ConvertionHandler returnUserRecord:searchResult atIndexPath:indexPath][@"cn"];
        
        NSDictionary *userRecord = [ConvertionHandler returnUserRecord:searchResult
                                                           atIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                          inSection:indexPath.section]];
        NSDictionary *temp = [ContactInfoHandler manipulateResultFromServer:userRecord];

    
        cell.firstNameLabel.text = name;
        [cell.callButton addTarget:self action:@selector(onCallClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.callButton setTitle:userRecord[@"cn"] forState:UIControlStateNormal];
        [cell.callButton setTitle:[temp[@"Phone"] objectAtIndex:0][@"mobile"] forState:UIControlStateSelected];
        cell.callButton.titleLabel.hidden = true;
        
        if (temp[@"photo"] != [NSNull null]){
            NSData *data = temp[@"photo"];
            cell.avatarImage.image = [UIImage imageWithData:data];
        }
        else
        {
            cell.avatarImage.image = [UIImage imageNamed:@"avatar.png"];
        }

    }
    else{
        NSString *cellValue = [ConvertionHandler returnUserRecord:dataArray atIndexPath:indexPath][@"cn"];
    
        NSDictionary *userRecord = [ConvertionHandler returnUserRecord:dataArray
                                                           atIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                          inSection:indexPath.section]];
        NSDictionary *temp = [ContactInfoHandler manipulateResultFromServer:userRecord];
        
        cell.firstNameLabel.text = cellValue;
        [cell.callButton addTarget:self action:@selector(onCallClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.callButton setTitle:userRecord[@"cn"] forState:UIControlStateNormal];
        [cell.callButton setTitle:[temp[@"Phone"] objectAtIndex:0][@"mobile"] forState:UIControlStateSelected];
        cell.callButton.titleLabel.hidden = true;
        if (temp[@"photo"] != [NSNull null]){
            NSData *data = temp[@"photo"];
            cell.avatarImage.image = [UIImage imageWithData:data];
        }
        else
        {
            cell.avatarImage.image = [UIImage imageNamed:@"avatar.png"];
        }
    }
    
    cell.lastNameLabel.text = nil;
    
 //   cell.avatarImage.image = [UIImage imageNamed:@"avatar.png"];
    
    for (int i = 0; i < onlineBuddies.count; i++){
     //   NSLog(@"check online name = %@",[onlineBuddies objectAtIndex:i]);
        
        if ([[cell.callButton titleForState:UIControlStateSelected] isEqualToString:(NSString *)[onlineBuddies objectAtIndex:i]]){
            cell.statusLight.image = [UIImage imageNamed:@"led_connected.png"];
            break;
        }
        else {
            cell.statusLight.image = [UIImage imageNamed:@"led_disconnected.png"];
        }
    }
    
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,300,60)] autorelease];
    
    // create image object
    UIImage *myImage = [UIImage imageNamed:@"folder_icon.png"];;
    
    // create the label objects
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(40,2,200,20);
    
    NSDictionary *dict = [dataArray objectAtIndex:section ];
    for (id key in dict)
        headerLabel.text = key;
    
    // create the imageView with the image in it
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:myImage] autorelease];
    imageView.frame = CGRectMake(3,2,30,18);
    
    customView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
                                  //lightGrayColor];
    [customView addSubview:imageView];
    [customView addSubview:headerLabel];
    return customView;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = [dataArray objectAtIndex:section ];
    NSString *tabInfo;
    for (id key in dict)
        tabInfo = key;
    return tabInfo;
    
}*/
#else
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [addressBookMap keyAtIndex: section];
}
#endif
#ifdef LINPHONE_ADDRESS


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([ContactSelection getSelectionMode] == ContactSelectionModeMessage){
        ChatRoomViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE], ChatRoomViewController);
        if(controller != nil) {
             NSDictionary *userRecord = [ConvertionHandler returnUserRecord:dataArray atIndexPath:indexPath];
            [controller setRemoteAddress:userRecord[@"cn"]];
        }
    }
    else{
        // Go to Contact details view
        DebugLog(@"flag linphone_address = %d", LINPHONE_ADDRESS);
        ContactDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ContactDetailsViewController compositeViewDescription] push:TRUE], ContactDetailsViewController);
        if(controller != nil) {
            DebugLog(@"");
            if (tableView == self.searchDisplayController.searchResultsTableView)
            {
                NSDictionary *userRecord = [ConvertionHandler returnUserRecord:searchResult atIndexPath:indexPath];
                controller.userRecord = userRecord;
           //     DebugLog(@"user record = %@", controller.userRecord);

            }
            else{
            // set value for ContactDetailViewController accordingly
                NSDictionary *userRecord = [ConvertionHandler returnUserRecord:dataArray atIndexPath:indexPath];
                controller.userRecord = userRecord;
           //     DebugLog(@"user record = %@", controller.userRecord);
            }
        }
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

- (void) onCallClick: (id) sender{
    UIButton *button = (UIButton *) sender;
   /* NSDictionary *userRecord = [ConvertionHandler returnUserRecord:dataArray
                                                       atIndexPath:[NSIndexPath indexPathForRow:button.titleLabel.tag
                                                                                inSection:button.tag]];
    NSDictionary *temp = [ContactInfoHandler manipulateResultFromServer:userRecord];
    NSLog(@"calling FMC number %@  contact = %@", [temp[@"Phone"] objectAtIndex:0][@"mobile"],
                                                        userRecord[@"cn"]);
*/
    NSString *name = [button titleForState:UIControlStateNormal];
    NSString *phone = [button  titleForState:UIControlStateSelected];
    
    //[[LinphoneManager instance] call:[temp[@"Phone"] objectAtIndex:0][@"mobile"]
    //                            displayName:userRecord[@"cn"]
    //                            transfer:NO];
    [[LinphoneManager instance] call:phone displayName:name transfer:NO];
}

-(NSDictionary *) getUserDataDict: (char *) number{
    
    
    NSString *userNumber = [NSString stringWithUTF8String: number];
    
    NSDictionary *result =[[NSDictionary alloc] initWithObjectsAndKeys:
                           userNumber , @"phone",
                           nil      ,   @"name",
                           nil      ,   @"photo",
                           nil];
    
   // if (dataArray == nil) return userNumber;
    if (dataArray == nil) return result;
    int section = [dataArray count];
    
    for (int i = 0; i < section; i++){
        
        NSDictionary *dict = [dataArray objectAtIndex:i ];
        NSArray *nameArray;
        
        for (id key in dict)
            nameArray = [dict objectForKey:key];
        
        int row =[nameArray count];
        
        for (int j = 0; j <row; j++)
        {
            NSDictionary *userRecord = [nameArray objectAtIndex:j];
            NSDictionary *temp = [self manipulateResultFromServer:userRecord];
            
            if ( [[temp[@"Phone"] objectAtIndex:0] [@"mobile"] isEqualToString:userNumber]
                || [[temp[@"Phone"] objectAtIndex:1] [@"home"] isEqualToString:userNumber])
            {
                return temp;
            }
        }
    }
    return result;
}

- (NSDictionary *)manipulateResultFromServer: (NSDictionary *) resultFromServer{
    
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    @try {
        [dict1 setObject:resultFromServer[@"departmentNumber"] forKey:@"mobile"];
    }
    @catch (NSException *exception) {
        
        [dict1 setObject:@"" forKey:@"mobile"];
    }
    @finally {
    }
    
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
    @try {
        [dict2 setObject:resultFromServer[@"homePhone"] forKey:@"home"];
    }
    @catch (NSException *exception) {
        [dict2 setObject:@"" forKey:@"home"];
    }
    @finally {
    }

    
    /*
    NSMutableDictionary *dict_name = [NSMutableDictionary dictionary];
    
    @try {
        [dict_name setObject:resultFromServer[@"cn"] forKey:@"name"];
    }
    @catch (NSException *exception) {
        
        [dict_name setObject:@"" forKey:@"name"];
    }
    @finally {
    }
    */
    
    NSString *dict_name = [[NSString alloc] init];
    @try {
        dict_name = resultFromServer[@"cn"] ;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    NSArray  * myArray1 = [NSArray arrayWithObjects:dict1, dict2, nil];
    
    
    
    NSObject *photo_string;
    
    @try{
        photo_string = resultFromServer[@"photo"];
    }
    @catch (NSException *exception) {
        photo_string = nil;
    }
    @finally {
    }
    
    NSDictionary * result = [[NSDictionary alloc] initWithObjectsAndKeys:
                             myArray1 ?: [NSNull null], @"Phone",
                             dict_name ?: [NSNull null], @"name",
                             photo_string ?: [NSNull null], @"photo",
                             nil];
    
    return result;
}
#pragma mark - XMPP Presence
- (LinphoneAppDelegate *)appDelegate {
	return (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)newBuddyOnline:(NSString *)buddyName{
    NSUserDefaults *serverName = [NSUserDefaults standardUserDefaults];
    buddyName = [buddyName stringByReplacingOccurrencesOfString:   [NSString stringWithFormat:@"@%@",[serverName stringForKey:@"serverName"]]
                                        withString:@""];
  //  NSLog(@"buddy name = %@", buddyName);
    if (![onlineBuddies containsObject:buddyName]){
        [onlineBuddies addObject:buddyName];
        [self.tableView reloadData];
    }
}

- (void) buddyWentOffline: (NSString *) buddyName{
    [onlineBuddies removeObject:buddyName];
    [self.tableView reloadData];
}

- (void) didDisconnect{
    [onlineBuddies removeAllObjects];
    [self.tableView reloadData];
    
}

#pragma mark - Search

- (void) filterContentForSearchText:(NSString *)searchText{
    [searchResult removeAllObjects];
    searchResult = [self searchUserData:searchText];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(NSMutableArray *) searchUserData: (NSString *) searchString{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    searchString = [searchString uppercaseString];
    
    if (!dataArray) return nil;
    int section = [dataArray count];
    
    for (int i = 0; i < section; i++){
        NSMutableArray *userArray = [[NSMutableArray alloc] init];
        NSDictionary *dict = [dataArray objectAtIndex:i];
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        NSArray *nameArray;
        NSString *keyw = [[NSString alloc] init];
        
        for (id key in dict){
            nameArray = [dict objectForKey:key];
            keyw = key;
        }
        int row =[nameArray count];
        
        for (int j = 0; j <row; j++)
        {
            NSDictionary *userRecord = [nameArray objectAtIndex:j];
            NSDictionary *temp = [self manipulateResultFromServer:userRecord];
            
            if (([[[temp[@"Phone"] objectAtIndex:0] [@"mobile"] uppercaseString] rangeOfString:searchString].location != NSNotFound)
                    || ([[[temp[@"Phone"] objectAtIndex:1] [@"home"] uppercaseString] rangeOfString:searchString].location != NSNotFound)
                        || ([[userRecord[@"cn"] uppercaseString] rangeOfString:searchString].location != NSNotFound ))

            {
                [userArray addObject:userRecord];
            }
        }
        [tempDict setObject:userArray forKey:keyw];
        [resultArray addObject:tempDict];
    }
    return resultArray;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar setText:@""];
}
@end
