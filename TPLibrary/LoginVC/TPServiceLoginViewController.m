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
    NSURLRequest *request = [_oauthClient requestWithMethod:@"get" path:@"/auth/new?user_id=1234&provider=fitbit" parameters:nil];

    [_webView loadRequest:request];
    _webView.delegate = self;
    
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
    NSLog(@"%@", requestString);
    
    if ([requestString hasPrefix:@"iosaction"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@"iosaction://"] objectAtIndex:1];
        BOOL done = logString.boolValue;
        NSLog(@"success: %i", done);
        return NO;
    }
    return YES;
}

@end
