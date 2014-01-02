//
//  ContactAddressDelegate.h
//  Vphone
//
//  Created by NinhNB on 31/12/13.
//
//

#import <Foundation/Foundation.h>

@protocol ContactAddressDelegate <NSObject>
-(NSString *) getUserDataDict: (char *) number;
@end
