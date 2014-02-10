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
        [dict2 setObject:resultFromServer[@"mobile"] forKey:@"home"];
    }
    @catch (NSException *exception) {
        [dict2 setObject:@"" forKey:@"home"];
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
    
    NSMutableDictionary *dict4 = [NSMutableDictionary dictionary];
    @try {
        [dict4 setObject:resultFromServer[@"title"] forKey:@"title"];
    }
    @catch (NSException *exception) {
        [dict4 setObject:@"" forKey:@"title"];
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
    
    NSObject *photo_string;
    
    @try{
        photo_string = resultFromServer[@"photo"];
    }
    @catch (NSException *exception) {
        photo_string = nil;
    }
    @finally {
    }
    /*
    NSMutableDictionary *photo_data = [NSMutableDictionary dictionary];
    @try {
        [photo_data setObject:resultFromServer[@"photo"] forKey:@"photo"];
    }
    @catch (NSException *exception) {
        
        [photo_data setObject:@"" forKey:@"photo"];
    }
    @finally {
    }
    */
    
    
    NSDictionary * result = [[NSDictionary alloc] initWithObjectsAndKeys:
                             myArray1 ?: [NSNull null], @"Phone",
                             myArray2 ?: [NSNull null], @"email",
                             dict4 ?: [NSNull null], @"title",
                             dict_name ?: [NSNull null], @"cn",
                             photo_string ?: [NSNull null], @"photo",
                             nil];
    
    
    return result;
}
@end
