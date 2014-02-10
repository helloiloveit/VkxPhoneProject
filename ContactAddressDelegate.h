//
//  ContactAddressDelegate.h
//  Vphone
//
//  Created by NinhNB on 31/12/13.
//
//

#import <Foundation/Foundation.h>

@protocol ContactAddressDelegate <NSObject>
-(NSDictionary *) getUserDataDict: (char *) number;
@end
