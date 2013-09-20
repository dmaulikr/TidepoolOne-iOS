//
//  TPServiceLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPServiceLoginViewController.h"
#import "TPOAuthClient.h"

@interface TPServiceLoginViewController ()
{
    TPOAuthClient *_oauthClient;
//    UIWebView *_webView;
}
@end

@implementation TPServiceLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _oauthClient = [TPOAuthClient sharedClient];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *path = [NSString stringWithFormat:@"/auth/new?user_id=%@&provider=fitbit", _oauthClient.user[@"id"]];
    NSURLRequest *request = [_oauthClient requestWithMethod:@"get" path:path parameters:nil];
    [_webView loadRequest:request];
    _webView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Service Connect Screen"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    requestString = [requestString lowercaseString];
    if ([requestString hasSuffix:@"success"]) {
        [self.delegate connectionMadeSucessfully:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([requestString hasSuffix:@"failure"]) {
        [self.delegate connectionMadeSucessfully:NO];
    }
    return YES;
}

@end
