//
//  TPOAuthClient.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>

@interface TPOAuthClient : AFHTTPClient

+ (TPOAuthClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

@property (nonatomic, strong) NSString *oauthAccessToken;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;

-(void)loginAndPresentUI:(bool)presentUI onViewController:(UIViewController *)vc withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;


-(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletingHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
-(void)deleteAllPasswords;

@end
