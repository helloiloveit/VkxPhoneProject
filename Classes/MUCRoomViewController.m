//
//  MUCRoomViewController.m
//  Vphone
//
//  Created by NinhNB on 18/11/13.
//
//

#import "MUCRoomViewController.h"
#import "PhoneMainView.h"

#import <NinePatch.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Utils.h"
#import "ConstantDefinition.h"
@interface MUCRoomViewController ()

@end

@implementation MUCRoomViewController

@synthesize MUCView, headerView, messageView;
@synthesize backButton, editButton, sendButton;
@synthesize chatRoomLabel;
@synthesize messageField;
@synthesize tableController;
@synthesize listTapGestureRecognizer;
@synthesize roomName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"MUCRoomViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        self->scrollOnGrowingEnabled = TRUE;
        self->chatRoom = NULL;
        
        self->listTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onListTap:)];
      }
    return self;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"MUCRoom"
                                                                content:@"MUCRoomViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:/*@"UIMainBar"*/nil
                                                          tabBarEnabled:false /*to keep room for chat*/
                                                             fullscreen:false
                                                          landscapeMode:true
                                                           portraitMode:true];
    }
    return compositeDescription;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
 //   [tableController setChatRoomDelegate:self];
    
 //   [editButton setBackgroundImage:[UIImage imageNamed:@"chat_ok_over.png"]
 //                         forState:(UIControlStateHighlighted | UIControlStateSelected)];

    //[LinphoneUtils buttonFixStates:editButton];
    
    messageField.minNumberOfLines = 1;
	messageField.maxNumberOfLines = ([LinphoneManager runningOnIpad])?10:3;
    messageField.delegate = self;
	messageField.font = [UIFont systemFontOfSize:18.0f];
    messageField.contentInset = UIEdgeInsetsMake(0, -5, -2, -5);
    messageField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    messageField.backgroundColor = [UIColor clearColor];
    [sendButton setEnabled:FALSE];
    
    [tableController.tableView addGestureRecognizer:listTapGestureRecognizer];
    [listTapGestureRecognizer setEnabled:FALSE];
    
    [tableController.tableView setBackgroundColor:[UIColor clearColor]]; // Can't do it in Xib: issue with ios4
    [tableController.tableView setBackgroundView:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMessageChange:)
												 name:UITextViewTextDidChangeNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textReceivedEvent:)
                                                 name:kLinphoneTextReceived
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coreUpdateEvent:)
                                                 name:kLinphoneCoreUpdate
                                               object:nil];
    
    if([tableController isEditing])
        [tableController setEditing:FALSE animated:FALSE];
    editButton.selected = FALSE;
    [[tableController tableView] reloadData];

}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [messageField resignFirstResponder];
    
    if(chatRoom != NULL) {
        linphone_chat_room_destroy(chatRoom);
        chatRoom = NULL;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneTextReceived
                                                  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
												  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneCoreUpdate
												  object:nil];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [TUNinePatchCache flushCache];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void) setRoomName:(NSString *)roomName{

}

- (void)applicationWillEnterForeground:(NSNotification*)notif {
    if(roomName != nil) {
       /***
        further imlementation on reading message
        ***/
        [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneTextReceived object:self];
    }
}
#pragma mark - Event Functions

- (void)coreUpdateEvent:(NSNotification*)notif {
    DebugLog(@"");
    if(![LinphoneManager isLcReady]) {
        chatRoom = NULL;
    }
}

- (void)textReceivedEvent:(NSNotification *)notif {
    DebugLog(@"");
    //LinphoneChatRoom *room = [[[notif userInfo] objectForKey:@"room"] pointerValue];
    //NSString *message = [[notif userInfo] objectForKey:@"message"];
    LinphoneAddress *from = [[[notif userInfo] objectForKey:@"from"] pointerValue];
    
	ChatModel *chat = [[notif userInfo] objectForKey:@"chat"];
    if(from == NULL || chat == NULL) {
        return;
    }
/*     char *fromStr = linphone_address_as_string_uri_only(from);
   if(fromStr != NULL) {
        if([[NSString stringWithUTF8String:fromStr]
            caseInsensitiveCompare:remoteAddress] == NSOrderedSame) {
            if (![[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]
                || [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [chat setRead:[NSNumber numberWithInt:1]];
                [chat update];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneTextReceived object:self];
            }
            [tableController addChatEntry:chat];
            [tableController scrollToLastUnread:TRUE];
        }
        ms_free(fromStr);
    }*/
}

#pragma mark - UITextFieldDelegate Functions

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    int diff = height - growingTextView.bounds.size.height;
    
    if(diff != 0) {
        CGRect messageRect = [messageView frame];
        messageRect.origin.y -= diff;
        messageRect.size.height += diff;
        [messageView setFrame:messageRect];
        
        // Always stay at bottom
        if(scrollOnGrowingEnabled) {
            CGRect tableFrame = [tableController.view frame];
            CGPoint contentPt = [tableController.tableView contentOffset];
            contentPt.y += diff;
            if(contentPt.y + tableFrame.size.height > tableController.tableView.contentSize.height)
                contentPt.y += diff;
            [tableController.tableView setContentOffset:contentPt animated:FALSE];
        }
        
        CGRect tableRect = [tableController.view frame];
        tableRect.size.height -= diff;
        [tableController.view setFrame:tableRect];
        
    }
}

#pragma mark - Action Functions

- (IBAction)onBackClick:(id)event {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)onEditClick:(id)event {
    editButton.selected = ![tableController isEditing];
    [tableController setEditing:![tableController isEditing] animated:TRUE];
    [messageField resignFirstResponder];
}

- (IBAction)onMessageChange:(id)sender {
    if([[messageField text] length] > 0) {
        [sendButton setEnabled:TRUE];
    } else {
        [sendButton setEnabled:FALSE];
    }
}

- (IBAction)onSendClick:(id)sender{
    DebugLog(@"");
    if([self sendMessage:[messageField text] to:roomName]) {
        scrollOnGrowingEnabled = FALSE;
        [messageField setText:@""];
        scrollOnGrowingEnabled = TRUE;
        [self onMessageChange:nil];
    }
    DebugLog(@"");
}

- (BOOL) sendMessage:(NSString*) aMessage to:(NSString *) aRoomName{
    if(![LinphoneManager isLcReady]) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot send message: Linphone core not ready"];
        return FALSE;
    }
    if(roomName == nil) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot send message: Null remoteAddress"];
        return FALSE;
    }
    if(chatRoom == NULL) {
		chatRoom = linphone_core_create_chat_room([LinphoneManager getLc], [roomName UTF8String]);
    }
    
    ChatModel *chat = [[ChatModel alloc] init];
    [chat setRemoteContact:roomName];
    [chat setLocalContact:@""];
    [chat setMessage:aMessage];
    
    [chat setDirection:[NSNumber numberWithInt:0]];
    [chat setTime:[NSDate date]];
    [chat setRead:[NSNumber numberWithInt:1]];
	[chat setState:[NSNumber numberWithInt:1]]; //INPROGRESS
    [chat create];
    
    [tableController addChatEntry:chat];
    [tableController scrollToBottom:TRUE];
 
    return YES;
}

#pragma mark - Keyboard Event Functions

- (void)keyboardWillHide:(NSNotification *)notif {
    //CGRect beginFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    //CGRect endFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    // Resize chat view
    {
        CGRect chatFrame = [[self MUCView] frame];
        chatFrame.size.height = [[self view] frame].size.height - chatFrame.origin.y;
        [[self MUCView] setFrame:chatFrame];
    }
    
    // Move header view
    {
        CGRect headerFrame = [headerView frame];
        headerFrame.origin.y = 0;
        [headerView setFrame:headerFrame];
    }
    
    // Resize & Move table view
    {
        CGRect tableFrame = [tableController.view frame];
        tableFrame.origin.y = [headerView frame].origin.y + [headerView frame].size.height;
        double diff = tableFrame.size.height;
        tableFrame.size.height = [messageView frame].origin.y - tableFrame.origin.y;
        diff = tableFrame.size.height - diff;
        [tableController.view setFrame:tableFrame];
        
        // Always stay at bottom
        CGPoint contentPt = [tableController.tableView contentOffset];
        contentPt.y -= diff;
        if(contentPt.y + tableFrame.size.height > tableController.tableView.contentSize.height)
            contentPt.y += diff;
        [tableController.tableView setContentOffset:contentPt animated:FALSE];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    //CGRect beginFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        int width = endFrame.size.height;
        endFrame.size.height = endFrame.size.width;
        endFrame.size.width = width;
    }
    
    // Resize chat view
    {
        CGRect viewFrame = [[self view] frame];
        CGRect rect = [PhoneMainView instance].view.bounds;
        CGPoint pos = {viewFrame.size.width, viewFrame.size.height};
        CGPoint gPos = [self.view convertPoint:pos toView:[UIApplication sharedApplication].keyWindow.rootViewController.view]; // Bypass IOS bug on landscape mode
        float diff = (rect.size.height - gPos.y - endFrame.size.height);
        if(diff > 0) diff = 0;
        CGRect chatFrame = [[self MUCView] frame];
        chatFrame.size.height = viewFrame.size.height - chatFrame.origin.y + diff;
        [[self MUCView] setFrame:chatFrame];
    }
    
    // Move header view
    {
        CGRect headerFrame = [headerView frame];
        headerFrame.origin.y = -headerFrame.size.height;
        [headerView setFrame:headerFrame];
    }
    
    // Resize & Move table view
    {
        CGRect tableFrame = [tableController.view frame];
        tableFrame.origin.y = [headerView frame].origin.y + [headerView frame].size.height;
        tableFrame.size.height = [messageView frame].origin.y - tableFrame.origin.y;
        [tableController.view setFrame:tableFrame];
    }
    
    // Scroll
    int lastSection = [tableController.tableView numberOfSections] - 1;
    if(lastSection >= 0) {
        int lastRow = [tableController.tableView numberOfRowsInSection:lastSection] - 1;
        if(lastRow >=0) {
            [tableController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:lastSection]
                                             atScrollPosition:UITableViewScrollPositionBottom
                                                     animated:TRUE];
        }
    }
    [UIView commitAnimations];
}

@end
