//
//  TPUser.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPUser.h"

@implementation TPUser

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.userDictionary = dictionary;
    }
    return self;
}

-(NSString *)id
{
    return [self nilForNSNullOrObject:_userDictionary[@"id"]];
}

-(NSArray *)authentications
{
    return [self nilForNSNullOrObject:_userDictionary[@"authentications"]];
}

-(NSString *)city
{
    return [self nilForNSNullOrObject:_userDictionary[@"city"]];
}

-(NSString *)country
{
    return [self nilForNSNullOrObject:_userDictionary[@"country"]];
}

-(NSString *)dateOfBirth
{
    return [self nilForNSNullOrObject:_userDictionary[@"date_of_birth"]];
}

-(NSString *)description
{
    return [self nilForNSNullOrObject:_userDictionary[@"description"]];
}

-(NSString *)displayName
{
    return [self nilForNSNullOrObject:_userDictionary[@"displayName"]];
}

-(NSString *)education
{
    return [self nilForNSNullOrObject:_userDictionary[@"education"]];
}

-(NSString *)email
{
    return [self nilForNSNullOrObject:_userDictionary[@"email"]];
}

-(NSString *)gender
{
    return [self nilForNSNullOrObject:_userDictionary[@"gender"]];
}

-(NSString *)name
{
    return [self nilForNSNullOrObject:_userDictionary[@"name"]];
}

-(NSString *)image
{
    return [self nilForNSNullOrObject:_userDictionary[@"image"]];
}


-(NSDictionary *)personality{
    return [self nilForNSNullOrObject:_userDictionary[@"personality"]];
}

-(NSArray *)aggregateResults
{
    return [self nilForNSNullOrObject:_userDictionary[@"aggregate_results"]];
}

-(NSString *)iosDeviceToken
{
    return [self nilForNSNullOrObject:_userDictionary[@"ios_device_token"]];
}

-(NSString *)friendStatus
{
    return [self nilForNSNullOrObject:_userDictionary[@"friend_status"]];
}

-(NSDictionary *)aggregateResultOfType:(NSString *)resultType
{
    NSArray *array = self.aggregateResults;
    for (NSDictionary *item in array) {
        if ([item[@"type"] isEqualToString:resultType]) {
            return item;
        }
    }
    return nil;
}

-(id)nilForNSNullOrObject:(id)object
{
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

@end
