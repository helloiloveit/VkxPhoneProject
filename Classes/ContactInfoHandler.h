//
//  ContactInfoHandler.h
//  linphone
//
//  Created by huyheo on 10/7/13.
//
//

#import <Foundation/Foundation.h>

@interface ContactInfoHandler : NSObject


+ (NSDictionary *)manipulateResultFromServer: (NSDictionary *) resultFromServer;
@end
