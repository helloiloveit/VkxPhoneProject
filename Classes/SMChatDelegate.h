//
//  SMChatDelegate.h
//  Vphone
//
//  Created by NinhNB on 14/1/14.
//
//

#import <Foundation/Foundation.h>

@protocol SMChatDelegate <NSObject>
- (void)newBuddyOnline:(NSString *)buddyName;
- (void) buddyWentOffline: (NSString *) buddyName;
- (void) didDisconnect;
@end
