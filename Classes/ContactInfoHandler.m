//
//  ContactInfoHandler.m
//  linphone
//
//  Created by huyheo on 10/7/13.
//
//

#import "ContactInfoHandler.h"
#import "ConstantDefinition.h"

@implementation ContactInfoHandler


+ (NSDictionary *)manipulateResultFromServer: (NSDictionary *) resultFromServer{
    //For test . server simulation
    
    
    
    
    
    /*
     NSDictionary * resultFromServer = [[NSDictionary alloc] initWithObjectsAndKeys:
     @"Mobile Phone" ?: [NSNull null], @"mobile",
     @"Mobile Phone" ?: [NSNull null], @"mail",
     @"Mobile Phone" ?: [NSNull null], @"homePhone",
     @"Mobile Phone" ?: [NSNull null], @"jpegPhoto",
     nil];
     */
    
    
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    @try {
        [dict1 setObject:resultFromServer[@"departmentNumber"] forKey:@"mobile"];
    }
    @catch (NSException *exception) {
        
        [dict1 setObject:@"" forKey:@"mobile"];
    }
    @finally {
    }
    
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
    @try {
        [dict2 setObject:resultFromServer[@"homePhone"] forKey:@"home"];
    }
    @catch (NSException *exception) {
        [dict2 setObject:@"043 8511432" forKey:@"home"];
    }
    @finally {
    }
    
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionary];
    @try {
        [dict3 setObject:resultFromServer[@"mail"] forKey:@"mail"];
    }
    @catch (NSException *exception) {
        [dict3 setObject:@"" forKey:@"mail"];
    }
    @finally {
    }
    
    
    NSMutableDictionary *dict_name = [NSMutableDictionary dictionary];
    
    @try {
        [dict_name setObject:resultFromServer[@"cn"] forKey:@"name"];
    }
    @catch (NSException *exception) {
        
        [dict_name setObject:@"" forKey:@"name"];
    }
    @finally {
    }
    
    NSArray  * myArray1 = [NSArray arrayWithObjects:dict1, dict2,  nil];
    
    NSArray  * myArray2 = [NSArray arrayWithObjects:dict3, nil];
    
    
    
    NSDictionary * result = [[NSDictionary alloc] initWithObjectsAndKeys:
                             myArray1 ?: [NSNull null], @"Phone",
                             myArray2 ?: [NSNull null], @"email",
                             dict_name ?: [NSNull null], @"cn",
                             nil];
    
    
    return result;
}
@end
