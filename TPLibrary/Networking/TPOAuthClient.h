//
//  TPOAuthClient.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//
#import <AFNetworking/AFHTTPClient.h>
#import "TPUser.h"

@interface TPOAuthClient : AFHTTPClient

@property (strong, nonatomic) NSDictionary *user;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) BOOL hasOauthToken;


+ (TPOAuthClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

#pragma mark OAuth methods
-(void)saveAndUseOauthToken:(NSString *)token;
-(NSString *)oauthToken;
-(void)deleteAllPasswords;

#pragma mark Actual Login methods
-(BOOL)loginPassively;
-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)loginFacebookWithTokenInfo:(NSDictionary *)facebookInfo;
-(void)authenticateWithFacebookToken:(NSDictionary *)facebookInfo;
-(void)logout;

#pragma mark API methods
-(void)getUserInfoFromServerWithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)handleError:(NSError *)error withOptionalMessage:(NSString *)message;

@end