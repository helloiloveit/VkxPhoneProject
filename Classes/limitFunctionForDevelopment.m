//
//  limitFunctionForDevelopment.m
//  linphone
//
//  Created by huyheo on 10/7/13.
//
//

#import "limitFunctionForDevelopment.h"

@implementation limitFunctionForDevelopment


+ (Boolean) limitUserClickableButton: (NSIndexPath *) indexPath{
    if (((indexPath.section != 0)&&(indexPath.section != 1)&&(indexPath.section !=3) )  || (indexPath.row != 0) ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"This function is not yet implemented. Pls come back later"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return FALSE;
    }
    return TRUE;
}

+ (void) limitUserClickableButton{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"This function is not yet implemented. Pls come back later"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end
