//
//  MUCTableViewController.h
//  Vphone
//
//  Created by NinhNB on 18/11/13.
//
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"

@interface MUCTableViewController : UITableViewController{
    @private NSMutableArray *data;
}

@property (nonatomic, copy) NSString *roomName;

- (void)addChatEntry:(ChatModel*)chat;
- (void)scrollToBottom:(BOOL)animated;
- (void)scrollToLastUnread:(BOOL)animated;
- (void)updateChatEntry:(ChatModel*)chat;

@end
