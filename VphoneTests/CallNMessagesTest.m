//
//  CallNMessagesTest.m
//  Vphone
//
//  Created by NinhNB on 11/11/13.
//
//

#import <XCTest/XCTest.h>
#import "DialerViewController.h"
#import "ChatModel.h"
#import "ChatRoomViewController.h"

@interface CallNMessagesTest : XCTestCase
{
    DialerViewController *dialerView;
    ChatRoomViewController *chatView;
    LinphoneChatRoom *chatRoom;
    LinphoneCore *lc;
    BOOL *stateChanged;
    LinphoneCoreVTable *vtable;
    
}


@end

@implementation CallNMessagesTest

- (void)setUp
{
    dialerView = [[DialerViewController alloc] init];
    chatView = [[ChatRoomViewController alloc] init];
    stateChanged = NO;
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

void message_status(LinphoneChatMessage* msg,LinphoneChatMessageState state,void* ud) {
    NSLog(@"State changed");
	ChatModel *chat = (__bridge ChatModel *)linphone_chat_message_get_user_data(msg);
	[LinphoneLogger log:LinphoneLoggerLog
				 format:@"Delivery status for [%@] is [%s]",(chat.message?chat.message:@""),linphone_chat_message_state_to_string(state)];
	[chat setState:[NSNumber numberWithInt:state]];
	[chat update];
	if (state != LinphoneChatMessageStateInProgress) {
		linphone_chat_message_set_user_data(msg, NULL);
    }
}


- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL*)externalUrl withInternalUrl:(NSURL*)internalUrl {
    
    if(![LinphoneManager isLcReady]) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot send message: Linphone core not ready"];
        return NO;
    }
    
    chatRoom = linphone_core_create_chat_room([LinphoneManager getLc], [@"1020" UTF8String]);
    
    // Save message in database
    ChatModel *chat = [[ChatModel alloc] init];
    [chat setRemoteContact:@"1020"];
    [chat setLocalContact:@""];
    
    [chat setMessage:@"test message"];
    
    [chat setDirection:[NSNumber numberWithInt:0]];
    [chat setTime:[NSDate date]];
    [chat setRead:[NSNumber numberWithInt:1]];
	[chat setState:[NSNumber numberWithInt:1]]; //INPROGRESS
    [chat create];
    
    LinphoneChatMessage* msg = linphone_chat_room_create_message(chatRoom, [@"test tasdasdase" UTF8String]);
	linphone_chat_message_set_user_data(msg, (__bridge void *)(chat));
    
	linphone_chat_room_send_message2(chatRoom, msg, message_status, (__bridge void *)(self));
    //linphone_core_iterate(lc);
    return TRUE;
}

-(void) testSendMessage
{
    if ([self sendMessage:@"testmessage" withExterlBodyUrl:nil withInternalUrl:nil]){
        NSLog(@"passed message");
    }
}

@end
