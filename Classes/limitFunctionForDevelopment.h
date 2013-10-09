//
//  limitFunctionForDevelopment.h
//  linphone
//
//  Created by huyheo on 10/7/13.
//
//

#import <Foundation/Foundation.h>

@interface limitFunctionForDevelopment : NSObject



// For Contact window
+ (Boolean) limitUserClickableButton: (NSIndexPath *) indexPath;

+ (void) limitUserClickableButton;
@end
