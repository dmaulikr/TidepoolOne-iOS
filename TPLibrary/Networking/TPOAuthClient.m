//
//  TPOAuthClient.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <SSKeychain/SSKeychain.h>
#import "TPLoginViewController.h"

#ifdef DEBUG
NSString * const kBaseURLString = @"https://tide-dev.herokuapp.com";
//NSString * const kBaseURLString = @"https://api.tidepool.co";
//NSString * const kBaseURLString = @"http://Kerems-iMac.local:7004";
//NSString * const kBaseURLString = @"https://tide-stage.herokuapp.com";
//NSString * const kBaseURLString = @"http://Mayanks-MacBook-Pro.local:7004";
#else
NSString * const kBaseURLString = @"https://tide-dev.herokuapp.com";
//NSString * const kBaseURLString = @"https://api.tidepool.co";
#endif


NSString * const kClientId = @"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1";
NSString * const kClientSecret = @"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706";

NSString * const kSSKeychainServiceName = @"Tidepool";

// Remote cache - date format - same as in TPTokenCaching
static NSString* kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";


@interface TPOAuthClient()<UIAlertViewDelegate>
{
    NSString *_clientId;
    NSString *_clientSecret;
    UIAlertView *_errorAlert;
    
    BOOL _isGettingUser;
    __block NSMutableArray *_userCompletionBlocks;
    __block NSMutableArray *_userFailureBlocks;
}
@end


@implementation TPOAuthClient

+ (TPOAuthClient *)sharedClient;
{
    static TPOAuthClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    _clientId = kClientId;
    _clientSecret = kClientSecret;
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	[self setDefaultHeader:@"Content-type" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    _userCompletionBlocks = [NSMutableArray array];
    return self;
}

-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (user) {
        NSString *pushToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
        if (pushToken && ![user[@"ios_device_token"] isEqualToString:pushToken]) {
            [self updateUserWithParameters:@{@"ios_device_token":pushToken} withCompletionHandlersSuccess:^{
            } andFailure:^{
            }];
    }
    }
}

#pragma mark OAuth methods

-(NSString *)oauthToken
{
    return [SSKeychain passwordForService:kSSKeychainServiceName account:kSSKeychainServiceName];
}

-(void)saveAndUseOauthToken:(NSString *)token
{
    [self deleteAllPasswords];
    [SSKeychain setPassword:token forService:kSSKeychainServiceName account:kSSKeychainServiceName];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",token]];
}


-(BOOL)hasOauthToken
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    return accounts.count;
}

-(BOOL)loginPassively
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    if (accounts.count > 0) {
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",[self oauthToken]]];
        self.isLoggedIn = 1;
        return 1;
    }
    return 0;
}


-(void)deleteAllPasswords
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    for (NSDictionary *account in accounts) {
        NSDictionary *account = accounts[0];
        NSString *username = account[@"acct"];
        [SSKeychain deletePasswordForService:kSSKeychainServiceName account:username];
    }
    accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
}

#pragma mark Actual Login methods
-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            @"password", @"response_type",
                            username, @"email",
                            password, @"password",
                            password, @"password_confirmation",
                            _clientId, @"client_id",
                            _clientSecret, @"client_secret",
                            nil];
    [self postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *token = [responseObject valueForKey:@"access_token"];
        [self saveAndUseOauthToken:token];
        self.user = responseObject[@"user"];
        self.isLoggedIn = 1;
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"An error occured while creating the account. Please try again."];
        failureBlock();
    }];
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            @"password", @"response_type",
                            username, @"email",
                            password, @"password",
                            _clientId, @"client_id",
                            _clientSecret, @"client_secret",
                            nil];
    [self postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *token = [responseObject valueForKey:@"access_token"];
        [self saveAndUseOauthToken:token];
        self.isLoggedIn = YES;
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"An error occured while logging in. Please try again."];
        failureBlock();
    }];
}

-(void)authenticateWithFacebookToken:(NSDictionary *)token
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [self getTidepoolOauthTokenInExchangeForFacebookUserInfo:user andFacebookToken:token];
             } else {
                 [self handleError:error withOptionalMessage:@"Facebook account authorization not done."];
             }
         }];
    }
}

-(void)getTidepoolOauthTokenInExchangeForFacebookUserInfo:(NSDictionary *)user andFacebookToken:(NSDictionary *)token
{
    if (!token) {
        return;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    
    //Facebook Token Data mapping
    NSDate *expiresDate = token[@"com.facebook.sdk:TokenInformationExpirationDateKey"];
    NSDate *refreshDate = token[@"com.facebook.sdk:TokenInformationRefreshDateKey"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:user[@"email"] forKey:@"email"];
    [info setValue:[NSString stringWithFormat:@"%@ %@",user[@"first_name"],user[@"last_name"]] forKey:@"name"];
    [info setValue:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", user[@"id"]] forKey:@"image"];
    [info setValue:[NSString stringWithFormat:@"%@ %@",user[@"first_name"],user[@"last_name"]] forKey:@"location"];
    [info setValue:user[@"gender"] forKey:@"gender"];
    
    [credentials setValue:token[@"com.facebook.sdk:TokenInformationTokenKey"] forKey:@"token"];
    [credentials setValue:[dateFormatter stringFromDate:refreshDate] forKey:@"refresh_at"];
    [credentials setValue:token[@"com.facebook.sdk:TokenInformationPermissionsKey"] forKey:@"permissions"];
    [credentials setValue:[dateFormatter stringFromDate:expiresDate] forKey:@"expires_at"];
    [credentials setValue:[NSNumber numberWithBool:YES] forKey:@"expires"];
    
    NSMutableDictionary *authHash = [NSMutableDictionary dictionary];
    [authHash setValue:@"facebook" forKey:@"provider"];
    [authHash setValue:user[@"id"] forKey:@"uid"];
    [authHash setValue:info forKey:@"info"];
    [authHash setValue:credentials forKey:@"credentials"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_clientId forKey:@"client_id"];
    [dict setObject:_clientSecret forKey:@"client_secret"];
    [dict setObject:@"password" forKey:@"grant_type"];
    [dict setObject:@"password" forKey:@"response_type"];
    [dict setObject:authHash forKey:@"auth_hash"];
    
    [self loginFacebookWithTokenInfo:dict];
}

-(void)loginFacebookWithTokenInfo:(NSDictionary *)facebookInfo
{
    [self postPath:@"/oauth/authorize" parameters:facebookInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveAndUseOauthToken:responseObject[@"access_token"]];
        self.user = responseObject[@"user"];
        self.isLoggedIn = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to get facebook auth working with Tidepool"];
    }];
}

-(void)setIsLoggedIn:(BOOL)isLoggedIn
{
    _isLoggedIn = isLoggedIn;
    if (isLoggedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged In" object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged Out" object:self userInfo:nil];
    }
    
}

-(void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    self.user = nil;
    [self clearAuthorizationHeader];
    [self deleteAllPasswords];
    self.isLoggedIn = 0;
}

#pragma mark API methods

-(void)getUserInfoLocallyIfPossibleWithCompletionHandlersSuccess:(void(^)(NSDictionary *user))successBlock andFailure:(void(^)())failureBlock;
{
    if (self.user) {
        successBlock(self.user);
    } else {
        [self forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:successBlock andFailure:failureBlock];
    }
}
-(void)forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:(void(^)(NSDictionary *user))successBlock andFailure:(void(^)())failureBlock;
{
    NSLog(@"GET USER INFO");
    // TODO: add failure Blocks
    [_userCompletionBlocks addObject:[successBlock copy]];
    if (!_isGettingUser) {
        NSLog(@"MAKE REQUEST");
        _isGettingUser = YES;
        [self getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.user = responseObject[@"data"];
            if (!self.isLoggedIn)
                self.isLoggedIn = 1;
            _isGettingUser = NO;
            for (id item in _userCompletionBlocks) {
                NSLog(@"running item off array");
                void (^block)(NSDictionary *user);
                block = item;
                block(self.user);
            }
            [_userCompletionBlocks removeAllObjects];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failureBlock();
            _isGettingUser = NO;
            [self handleError:error withOptionalMessage:@"An error occured while getting user info from Tidepool."];
        }];
    }
}

-(void)updateUserWithParameters:(NSDictionary *)parameters withCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    [self putPath:@"api/v1/users/-/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.user = responseObject[@"data"];
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
        [self handleError:error withOptionalMessage:@"There was an error saving data. Please try again."];
    }];

}


-(void)getNewGameOfType:(NSString *)type WithCompletionHandlersSuccess:(void(^)(id dataObject))successBlock andFailure:(void(^)())failureBlock
{
    [self postPath:[NSString stringWithFormat:@"api/v1/users/-/games?def_id=%@", type] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject[@"data"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to get game"];
    }];
}

-(void)postGameEvents:(NSDictionary *)events withCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    [self postPath:@"/api/v1/user_events" parameters:events success:^(AFHTTPRequestOperation *operation, id dataObject) {
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Error submitting performance"];
        failureBlock();
    }];
    
    
}

-(void)getGameResultsForGameId:(NSNumber *)gameId WithCompletionHandlersSuccess:(void(^)(id dataObject))successBlock andFailure:(void(^)())failureBlock
{
    [self getPath:[NSString stringWithFormat:@"api/v1/users/-/games/%@/results", gameId] parameters:nil success:^(AFHTTPRequestOperation *operation, id dataObject) {
        successBlock(dataObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to get game results"];
        failureBlock();
    }];
}


#pragma mark API methods - friends
-(void)findFriendsWithEmail:(NSArray *)emailList WithCompletionHandlersSuccess:(void(^)(NSArray *newUsers))successBlock andFailure:(void(^)())failureBlock
{
    NSMutableURLRequest *request = [self requestWithMethod:@"get" path:@"api/v1/users/-/friends/find" parameters:nil];
    
    NSDictionary *jsonDic = @{
                                     @"friend_list":@{@"emails":@[
                                                              @"mayank.ot@gmail.com",
                                                              ],
                                                          },
                                     };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog([responseObject description]);        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Could not find friends"];
        failureBlock();
    }];
//    [self enqueueHTTPRequestOperation:operation];
    [operation start];
//    [self getPath:@"api/v1/users/-/friends/find" parameters:@{@"emails":emailList} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([responseObject description]);        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self handleError:error withOptionalMessage:@"Could not find friends"];
//        failureBlock();
//    }];
}
-(void)findFriendsWithFacebookIds:(NSArray *)facebookIdList WithCompletionHandlersSuccess:(void(^)(NSArray *newUsers))successBlock andFailure:(void(^)())failureBlock
{
    [self getPath:@"api/v1/users/-/friends/find" parameters:@{@"facebook_ids":facebookIdList} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog([responseObject description]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Could not find friends"];
        failureBlock();
    }];
}

#pragma mark API methods - leaderboards
-(void)getLeaderboardsForGame:(NSString *)game WithCompletionHandlersSuccess:(void(^)(NSArray *leaders))successBlock andFailure:(void(^)())failureBlock
{
    [self getPath:[NSString stringWithFormat:@"api/v1/games/%@/leaderboard?offset=0&limit=10", game] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject[@"data"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to download leaderboard"];
    }];
}
-(void)getFriendsLeaderboardsForGame:(NSString *)game WithCompletionHandlersSuccess:(void(^)(NSArray *leaders))successBlock andFailure:(void(^)())failureBlock
{
    [self getPath:[NSString stringWithFormat:@"api/v1/users/-/games/%@/leaderboard?offset=0&limit=10", game] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject[@"data"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to download leaderboard"];
    }];
    
}



-(void)deleteConnectionForProvider:(NSString *)provider
{
    [self deletePath:[NSString stringWithFormat:@"api/v1/users/-/connections/%@", provider] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Fire and forget
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:[NSString stringWithFormat:@"Couldn't disconnect %@", provider]];
    }];

}


#pragma mark Helper methods
-(void)handleError:(NSError *)error withOptionalMessage:(NSString *)message
{
    int httpErrorCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    if (_errorAlert) {
        return;
    }
    if (httpErrorCode == 401) {
        _errorAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Error" message:@"Please login again" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        _errorAlert.delegate = self;
        [_errorAlert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthClient error" object:nil];
        [self logout];
        return;
    }
    NSString *errorMessage = [error localizedDescription];
    if (errorMessage) {
        message = errorMessage;
    }
    _errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    _errorAlert.delegate = self;
    [_errorAlert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthClient error" object:nil];
}


-(NSDate *)dateFromString:(NSString *)stringDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    // below is hack for pre-iOS 7
    NSMutableString *dateString = [stringDate mutableCopy];
    if ([dateString characterAtIndex:26] == ':') {
        [dateString deleteCharactersInRange:NSMakeRange(26, 1)];
    }
    return [dateFormatter dateFromString:dateString];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _errorAlert = nil;
}

@end
