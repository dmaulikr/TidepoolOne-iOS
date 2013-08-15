//
//  TPTokenCachingStrategy.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTokenCachingStrategy.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import "TPOAuthClient.h"

// Local vs. Remote flag
// Set to local initially. You can change to the remote endpoint
// once you've set up your remote token caching endpoint.
static BOOL kLocalCache = NO;

// Local cache - unique file info
static NSString* kFilename = @"GuessMyMoodTokenInfo.plist";

// Remote cache - date format
static NSString* kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";

@interface TPTokenCachingStrategy()
@property (nonatomic, strong) NSString *tokenFilePath;
- (NSString *) filePath;
@end

@implementation TPTokenCachingStrategy

#pragma mark - Initialization methods
/*
 * Init method.
 */
- (id) init
{
    self = [super init];
    if (self) {
        _tokenFilePath = [self filePath];
    }
    return self;
}

#pragma FBTokenCachingStrategy override methods

/*
 * Override method called to cache token.
 */
- (void)cacheFBAccessTokenData:(FBAccessTokenData *)accessToken
{
    NSDictionary *tokenInformation = [accessToken dictionary];
    if (kLocalCache) {
        [self writeData:tokenInformation];
    } else {
        [self writeDataRemotely:tokenInformation];
    }
}

/*
 * Override method to fetch token.
 */
- (FBAccessTokenData *)fetchFBAccessTokenData
{
    NSDictionary *tokenInformation;
    if (kLocalCache) {
        tokenInformation = [self readData];
    } else {
        tokenInformation = [self readDataRemotely];
    }
    if (nil == tokenInformation) {
        return nil;
    } else {
        return [FBAccessTokenData createTokenFromDictionary:tokenInformation];
    }
}

/*
 * Override method to clear token.
 */
- (void)clearToken
{
    if (kLocalCache) {
        [self writeData:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
    } else {
        [self writeDataRemotely:[NSDictionary dictionaryWithObjectsAndKeys:nil]];
    }
}

#pragma mark - Local caching helper methods

/*
 * Helper method to get the local file path.
 */
- (NSString *) filePath {
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

/*
 * Helper method to write data.
 */
- (void) writeData:(NSDictionary *) data {
    NSLog(@"File = %@ and Data = %@", self.tokenFilePath, data);
    BOOL success = [data writeToFile:self.tokenFilePath atomically:YES];
    if (!success) {
        NSLog(@"Error writing to file");
    }
}

/*
 * Helper method to read data.
 */
- (NSDictionary *) readData {
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:self.tokenFilePath];
    NSLog(@"File = %@ and data = %@", self.tokenFilePath, data);
    return data;
}


#pragma mark - Remote caching helper methods

/*
 * Helper method to look for strings that represent dates and
 * convert them to NSDate objects.
 */
- (NSMutableDictionary *) dictionaryDateParse: (NSDictionary *) data {
    // Date format for date checks
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    // Dictionary to return
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    // Enumerate through the input dictionary
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // Check if strings are dates
        if ([obj isKindOfClass:[NSString class]]) {
            NSDate *objDate = nil;
            BOOL isDate = [dateFormatter getObjectValue:&objDate
                                              forString:obj
                                       errorDescription:nil];
            if (isDate) {
                resultDictionary[key] = objDate;
                [resultDictionary setObject:objDate forKey:key];
            } else {
                resultDictionary[key] = obj;
            }
        } else {
            // Non-string, just keep as-is
            resultDictionary[key] = obj;
        }
    }];
    return resultDictionary;
}

/*
 * Helper method to write data.
 */
- (void) writeDataRemotely:(NSDictionary *) data {
    NSLog([data description]);

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];


    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:@"mayank.ot@gmail.com" forKey:@"email"];
    [info setValue:@"Mayank Sanganeria" forKey:@"name"];
    [info setValue:@"http://google.com" forKey:@"image"];
    
    NSDate *expiresDate = data[@"com.facebook.sdk:TokenInformationExpirationDateKey"];
    NSDate *refreshDate = data[@"com.facebook.sdk:TokenInformationRefreshDateKey"];
    
    NSMutableDictionary *credentials = [NSMutableDictionary dictionary];
    [credentials setValue:data[@"com.facebook.sdk:TokenInformationTokenKey"] forKey:@"token"];
    [credentials setValue:[dateFormatter stringFromDate:refreshDate] forKey:@"refresh_at"];
    [credentials setValue:data[@"com.facebook.sdk:TokenInformationPermissionsKey"] forKey:@"permissions"];

    [credentials setValue:[dateFormatter stringFromDate:expiresDate] forKey:@"expires_at"];
    [credentials setValue:[NSNumber numberWithBool:YES] forKey:@"expires"];
    
    NSMutableDictionary *authHash = [NSMutableDictionary dictionary];
    [authHash setValue:@"facebook" forKey:@"provider"];
    [authHash setValue:@"221000190" forKey:@"uid"];
    [authHash setValue:info forKey:@"info"];
    [authHash setValue:credentials forKey:@"credentials"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"mayank.ot@gmail.com" forKey:@"user_id"];
    [dict setObject:@"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1" forKey:@"client_id"];
    [dict setObject:@"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706" forKey:@"client_secret"];
    [dict setObject:@"password" forKey:@"grant_type"];
    [dict setObject:@"password" forKey:@"response_type"];
    [dict setObject:authHash forKey:@"auth_hash"];

    NSLog([dateFormatter stringFromDate:refreshDate]);
    NSLog([dateFormatter stringFromDate:expiresDate]);
    
    NSLog([dict description]);
    
    [[TPOAuthClient sharedClient] postPath:@"/oauth/authorize" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"boo:%@",[responseObject description]);
        [[TPOAuthClient sharedClient] saveAndUseOauthToken:responseObject[@"access_token"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog([error description]);
    }];    
}

/*
 * Helper method to read data.
 */
- (NSDictionary *) readDataRemotely {
}

@end
