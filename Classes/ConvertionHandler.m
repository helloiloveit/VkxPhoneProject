//
//  ConvertionHandler.m
//  linphone
//
//  Created by huyheo on 10/4/13.
//
//

#import "ConvertionHandler.h"
#import "ConstantDefinition.h"
@implementation ConvertionHandler



+ (NSDictionary *) returnUserRecord :(NSArray *) usersData atIndexPath: (NSIndexPath *) indexPath {
    NSDictionary *dict = [usersData objectAtIndex:indexPath.section ];
    InfoLog(@"dict = %@",[dict description]);
    NSArray *nameArray;
    for (id key in dict)
        nameArray = [dict objectForKey:key];
    
    InfoLog(@"nameArray = %@", nameArray);
    NSDictionary *userRecord = [nameArray objectAtIndex:indexPath.row];
    return userRecord;
}


@end
