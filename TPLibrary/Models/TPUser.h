//
//  TPUser.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPUser : NSObject

-(id)initWithDictionary:(NSDictionary *)dictionary;

@property (strong, nonatomic) NSArray *authentications;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *dateOfBirth;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *education;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSDictionary *personality;
@property (strong, nonatomic) NSArray *aggregateResults;
@property (strong, nonatomic) NSString *iosDeviceToken;
@property (strong, nonatomic) NSString *friendStatus;
@property (strong, nonatomic) NSDictionary *userDictionary;

-(NSDictionary *)aggregateResultOfType:(NSString *)resultType;

@end
