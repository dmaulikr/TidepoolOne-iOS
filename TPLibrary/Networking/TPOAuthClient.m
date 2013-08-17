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

//NSString * const kBaseURLString = @"https://tide-stage.herokuapp.com";
NSString * const kBaseURLString = @"https://tide-dev.herokuapp.com";
//NSString * const kBaseURLString = @"http://Mayanks-MacBook-Pro.local:7004";
//NSString * const kBaseURLString = @"http://Kerems-iMac.local:7004";

NSString * const kClientId = @"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1";
NSString * const kClientSecret = @"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706";

NSString * const kSSKeychainServiceName = @"Tidepool";

// Remote cache - date format - same as in TPTokenCaching
static NSString* kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";


@interface TPOAuthClient()
{
    NSString *_clientId;
    NSString *_clientSecret;
    
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
    return self;
}

-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"password", @"grant_type",
//                            @"password", @"response_type",
                            username, @"email",
                            password, @"password",
                            _clientId, @"client_id",
                            _clientSecret, @"client_secret",
                            nil];
    [self postPath:@"api/v1/users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        [self loginWithUsername:username password:password withCompletingHandlersSuccess:successBlock andFailure:failureBlock];
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
        NSLog(@"success");
        NSString *token = [responseObject valueForKey:@"access_token"];
        [self saveAndUseOauthToken:token];
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"An error occured while logging in. Please try again."];
        failureBlock();
    }];
}

-(NSString *)oauthToken
{
    return [SSKeychain passwordForService:kSSKeychainServiceName account:kSSKeychainServiceName];
}

-(void)saveAndUseOauthToken:(NSString *)token
{
    NSLog(@"called save oauth token");
    [self deleteAllPasswords];
    [SSKeychain setPassword:token forService:kSSKeychainServiceName account:kSSKeychainServiceName];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",token]];
    [self getUserInfoFromServer];
}

-(void)saveUserInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:self.user forKey:@"TidepoolUser"];
}

-(void)setUser:(TPUser *)user
{
    _user = user;
    NSLog(@"changed user to %@", [user description]);
}

-(TPUser *)getUserInfo
{
    NSLog(@"debug:%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"TidepoolUser"] description]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"TidepoolUser"];
}

-(BOOL)hasOauthToken
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    NSLog(@"Checking num of saved oauth tokens: %i", accounts.count);
    return accounts.count;
}

-(BOOL)loginPassively
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    NSLog(@"Checking for accounts: %i %@", accounts.count, [accounts description]);
    if (accounts.count > 0) {
        NSLog(@"got into the inner loop only if accounts exist");
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",[self oauthToken]]];
        self.user = [self getUserInfo];
        self.isLoggedIn = 1;
        return 1;
    }
    return 0;
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

-(void)deleteAllPasswords
{
    NSArray *accounts = [SSKeychain accountsForService:kSSKeychainServiceName];
    NSLog(@"Checking for accounts pre deletion: %@", [accounts description]);
    for (NSDictionary *account in accounts) {
        NSDictionary *account = accounts[0];
        NSString *username = account[@"acct"];
        [SSKeychain deletePasswordForService:kSSKeychainServiceName account:username];
    }
    accounts = [SSKeychain accountsForService:kSSKeychainServiceName];    
    NSLog(@"Checking for accounts post deletion: %@", [accounts description]);

}

-(void)logout
{
    NSLog(@"Loggin out OauthClient");
    [[FBSession activeSession] closeAndClearTokenInformation];
    [self clearAuthorizationHeader];
    [self deleteAllPasswords];
    self.isLoggedIn = 0;
}

-(void)getUserInfoFromServer
{
    [self getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.user = responseObject[@"data"];
        self.isLoggedIn = 1;
        [self saveUserInfo];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"An error occured while getting user info from Tidepool."];
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
                 NSLog([user description]);
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
        NSLog(@"token empty");
        return;
    } else {
        NSLog(@"token not empty");
    }
    NSLog(@"Facebook Data:%@",[token description]);
    
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
    
    [[TPOAuthClient sharedClient] postPath:@"/oauth/authorize" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[TPOAuthClient sharedClient] saveAndUseOauthToken:responseObject[@"access_token"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withOptionalMessage:@"Unable to get facebook auth working with Tidepool"];
    }];
}

-(void)handleError:(NSError *)error withOptionalMessage:(NSString *)message
{
    NSString *errorMessage = [error localizedDescription];
    if (errorMessage) {
        message = errorMessage;
    }
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthClient error" object:nil];
}

@end
