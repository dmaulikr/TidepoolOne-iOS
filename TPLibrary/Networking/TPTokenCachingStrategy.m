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
static NSString* kFBDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";


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
    [dateFormatter setDateFormat:kFBDateFormat];
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
    [[TPOAuthClient sharedClient] authenticateWithFacebookToken:data];
}

/*
 * Helper method to read data.
 */
- (NSDictionary *) readDataRemotely {
    //TODO: fix this
    return nil;
}

@end
