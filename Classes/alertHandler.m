//
//  alertHandler.m
//  Vphone
//
//  Created by huyheo on 10/11/13.
//
//

#import "alertHandler.h"

@implementation alertHandler
+ (void) contactListError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"opps"
                                                    message:@"Something wrong happen while trying to get contact list from server"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
