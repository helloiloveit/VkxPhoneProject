//
//  MUCRoomViewController.h
//  Vphone
//
//  Created by NinhNB on 18/11/13.
//
//

#import <UIKit/UIKit.h>

#import "UIToggleButton.h"
#import "UICompositeViewController.h"
#import "HPGrowingTextView.h"
#import "ChatModel.h"
#import "ImagePickerViewController.h"
#import "ImageSharing.h"
#import "OrderedDictionary.h"
#import "MUCTableViewController.h"

#include "linphonecore.h"

@interface MUCRoomViewController : UIViewController <HPGrowingTextViewDelegate,UICompositeViewDelegate>{
    LinphoneChatRoom *chatRoom;
    BOOL scrollOnGrowingEnabled;

}
@property (strong, nonatomic) IBOutlet MUCTableViewController *tableController;

@property (strong, nonatomic) IBOutlet UIView *MUCView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *messageView;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) IBOutlet UILabel *chatRoomLabel;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *messageField;

@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *listTapGestureRecognizer;

@property (nonatomic, copy) NSString *roomName;

- (IBAction)onBackClick:(id)event;
- (IBAction)onEditClick:(id)event;
- (IBAction)onMessageChange:(id)sender;
- (IBAction)onSendClick:(id)sender;


@end
