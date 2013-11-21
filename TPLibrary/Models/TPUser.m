//
//  TPUser.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPUser.h"

@implementation TPUser

-(NSString *)id
{
    return _userDictionary[@"id"];
}

-(NSArray *)authentications
{
    return _userDictionary[@"authentications"];
}

-(NSString *)city
{
    return _userDictionary[@"city"];
}

-(NSString *)country
{
    return _userDictionary[@"country"];
}

-(NSString *)dateOfBirth
{
    return _userDictionary[@"date_of_birth"];
}

-(NSString *)description
{
    return _userDictionary[@"description"];
}

-(NSString *)displayName
{
    return _userDictionary[@"displayName"];
}

-(NSString *)education
{
    return _userDictionary[@"education"];
}

-(NSString *)email
{
    return _userDictionary[@"email"];
}

-(NSString *)gender
{
    return _userDictionary[@"gender"];
}

-(NSString *)name
{
    return _userDictionary[@"name"];
}

-(NSString *)image
{
    return _userDictionary[@"image"];
}


-(NSDictionary *)personality{
    return _userDictionary[@"personality"];
}

-(NSArray *)aggregateResults
{
    return _userDictionary[@"aggregate_results"];
}

-(NSString *)iosDeviceToken
{
    return _userDictionary[@"ios_device_token"];
}

-(NSString *)friendStatus
{
    return _userDictionary[@"friend_status"];
}
@end
