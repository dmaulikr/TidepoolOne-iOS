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

@property (strong, nonatomic) TPUser *user;

+ (TPOAuthClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

-(BOOL)isLoggedIn;

-(void)loginAndPresentUI:(bool)presentUI onViewController:(UIViewController *)vc withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;



-(void)saveAndUseOauthToken:(NSString *)token;


-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;

-(void)createAccountWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;

-(void)deleteAllPasswords;

-(void)logout;

-(void)authenticateWithFacebookToken:(NSDictionary *)facebookInfo;



@end