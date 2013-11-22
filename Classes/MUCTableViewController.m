//
//  MUCTableViewController.m
//  Vphone
//
//  Created by NinhNB on 18/11/13.
//
//

#import "MUCTableViewController.h"
#import "UIChatRoomCell.h"
#import "LinphoneManager.h"

#import "PhoneMainView.h"

#import "Utils.h"
#import <NinePatch.h>

@interface MUCTableViewController ()

@end

@implementation MUCTableViewController
@synthesize roomName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TUNinePatchCache flushCache]; // Clear cache
    if(data != nil) {
        [data removeAllObjects];
        data = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - entry

-(void) loadData{
    if(data != nil) {
        [data removeAllObjects];
    }
    
    //load chat data
    
    [[self tableView] reloadData];
    [self scrollToLastUnread:false];
}

- (void)addChatEntry:(ChatModel*)chat {
    if(data == nil) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot add entry: null data"];
        return;
    }
    [self.tableView beginUpdates];
    int pos = [data count];
    [data insertObject:chat atIndex:pos];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:pos inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)updateChatEntry:(ChatModel*)chat {
    if(data == nil) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot update entry: null data"];
        return;
    }
	NSInteger index = [data indexOfObject:chat];
    if (index<0) {
		[LinphoneLogger logc:LinphoneLoggerWarning format:"chat entries does not exixt"];
		return;
	}
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:FALSE];; //just reload
	return;
}

#pragma mark - scroll

- (void)scrollToBottom:(BOOL)animated {
    CGSize size = [self.tableView contentSize];
    CGRect bounds = [self.tableView bounds];
    bounds.origin.y = size.height - bounds.size.height;
    
    [self.tableView.layer removeAllAnimations];
    [self.tableView scrollRectToVisible:bounds animated:animated];
}

- (void)scrollToLastUnread:(BOOL)animated {
    if(data == nil) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot add entry: null data"];
        return;
    }
    
    int index = -1;
    // Find first unread & set all entry read
    for(int i = 0; i <[data count]; ++i) {
        ChatModel *chat = [data objectAtIndex:i];
        if([[chat read] intValue] == 0) {
            [chat setRead:[NSNumber numberWithInt:1]];
            if(index == -1)
                index = i;
        }
    }
    if(index == -1) {
        index = [data count] - 1;
    }
    
    // Scroll to unread
    if(index >= 0) {
        [self.tableView.layer removeAllAnimations];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:animated];
    }
}
#pragma mark - Property Functions

- (void)setRoomName:(NSString *)aRoomName{
    self->roomName = [aRoomName copy];
    [self loadData];
}

#pragma mark - UITableViewDelegate Functions

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        ChatModel *chat = [data objectAtIndex:[indexPath row]];
        [data removeObjectAtIndex:[indexPath row]];
        [chat delete];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatModel *chat = [data objectAtIndex:[indexPath row]];
    return [UIChatRoomCell height:chat width:[self.view frame].size.width];
}

@end
