//
//  SMMessageDelegate.h
//  linphone
//
//  Created by NinhNB on 11/10/13.
//
//

#import <Foundation/Foundation.h>

@protocol SMMessageDelegate <NSObject>
-(void) newMessageReceived:(NSDictionary *) messageContent;
@end
