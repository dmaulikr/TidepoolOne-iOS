//
//  TPOAuthClient.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>

//NSString * const kBaseURLString = @"https://tide-dev.herokuapp.com";
//NSString * const kClientId = @"https://tide-dev.herokuapp.com";
//NSString * const kClientSecret = @"https://tide-dev.herokuapp.com";

NSString * const kBaseURLString = @"http://api-server.dev";
NSString * const kClientId = @"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1";
NSString * const kClientSecret = @"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706";


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

@end
