//
//  TPOAuthClient.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TPOAuthClient : AFHTTPClient

+ (TPOAuthClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

@property (nonatomic, strong) NSString *oauthAccessToken;

@end
