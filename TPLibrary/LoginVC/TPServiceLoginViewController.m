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
    void(^_successBlock)(void);
    void(^_failureBlock)(void);
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
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Service Connect Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Service Connect Screen"];
#endif

}

-(void)setCompletionHandlersSuccess:(void (^)())successBlock andFailure:(void (^)())failureBlock
{
    _successBlock = successBlock;
    _failureBlock = failureBlock;
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
        [self.navigationController popViewControllerAnimated:YES];
        _successBlock();
        return NO;
    } else if ([requestString hasSuffix:@"failure"]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to Fitbit. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil] show];
        return NO;
    }
    return YES;
}

@end
