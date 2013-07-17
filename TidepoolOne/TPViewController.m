//
//  TPViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPViewController.h"
#import "TPOAuthClient.h"

@interface TPViewController ()
{
    TPOAuthClient *_sharedClient;
}
@end

@implementation TPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sharedClient = [TPOAuthClient sharedClient];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            @"password", @"response_type",
                            @"msanganeria@tidepool.co", @"email",
                            @"asdfasdf", @"password",
                            @"773cc7e7690e0f541cfc81a9d6df50721c520086bfc63460b5339747b0531cbc", @"client_id",
                            @"b2e891c55531e121b9367e16ea7dde7ad9071399b1e554ead9550ec1858bb782", @"client_secret",
                            nil];
    NSURLRequest *request = [_sharedClient requestWithMethod:@"post" path:@"oauth/authorize" parameters:params];
    AFHTTPRequestOperation *operation = [_sharedClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        NSLog([responseObject description]);
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        [_sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",_sharedClient.oauthAccessToken]];
    
        NSURLRequest *request1 = [_sharedClient requestWithMethod:@"post" path:@"api/v1/user/-/games?def_id=reaction_time" parameters:nil];
        NSLog([[request1 allHTTPHeaderFields] description]);
        
        [_sharedClient postPath:@"api/v1/users/-/games?def_id=reaction_time" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            NSLog([responseObject description]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure");
            NSLog([error description]);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        NSLog([error description]);
    }];
//    NSLog([NSString stringWithUTF8String:[[request HTTPBody] bytes]]);
    [_sharedClient enqueueHTTPRequestOperation:operation];
//    [_sharedClient postPath:@"oauth/authorize" parameters:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                           @"grant_type", @"password",
//                                                           @"response_type", @"password",
//                                                           @"email",@"mayankot@gmail.com",
//                                                           @"password",@"12345678",
//                                                           @"client_id",@"8e8cb313e0f78fb50906ba26635957876dc757070b923aef8b6f5f993b1cec40",
//                                                           @"client_secret", @"3e41711d84ce061788ea5656a6b71ae11bd784f8560eb8f5f058d3e7ce6e8ef5",
//                                                           nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success");
//        NSLog([responseObject description]);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure");
//        NSLog([error description]);
//    }];
    
        
//    }];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    NSLog(@"%i",webView.loading);
    NSLog([webView description]);
    [webView loadRequest:req];
    NSLog(@"%i",webView.loading);
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
