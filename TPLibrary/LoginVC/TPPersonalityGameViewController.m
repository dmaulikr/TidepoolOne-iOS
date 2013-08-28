//
//  TPPersonalityGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPersonalityGameViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <JSONKit/JSONKit.h>

@interface TPPersonalityGameViewController ()
{
    UIWebView *_webView;
    TPLabel *_messageLabel;
    TPOAuthClient *_oauthClient;
    MBProgressHUD *_loadingGameHud;
    NSTimer *_timeoutTimer;
}
@end

@implementation TPPersonalityGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float kPadding = 10;
	// Do any additional setup after loading the view.
    _oauthClient = [TPOAuthClient sharedClient];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height +20)]; // for status bar
    imageView.image = [UIImage imageNamed:@"Default.png"];
    [self.view addSubview:imageView];
    _messageLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, self.view.bounds.size.width - kPadding, 350)];
    _messageLabel.text = @"Starting personality Game";
    _messageLabel.numberOfLines = 0;
    _messageLabel.centered = YES;
    [self.view addSubview:_messageLabel];
    
    TPButton *button = [[TPButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/3, 50)];
    button.center = CGPointMake(self.view.bounds.size.width/4, 250);
    [button setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
    [button setTitle:@"Play again" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startNewPersonalityGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [[TPButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/3, 50)];
    button.center = CGPointMake(3*self.view.bounds.size.width/4, 250);
    [button setTitle:@"Logout" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];    
    [self startNewPersonalityGame];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+20); //for status bar
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    requestString = [requestString lowercaseString];
    
    NSLog(@"FromWebView: %@", requestString);
    
    if ([requestString hasPrefix:@"ios"]) {
        //old web version
        if ([requestString hasPrefix:@"iosaction"]) {
            NSString *action = [requestString componentsSeparatedByString:@"://"][1];
            BOOL done = [action boolValue];
            if (done) {
                [self personalityGameFinishedSuccessfully];
            } else {
                _messageLabel.text = @"There was an error. Please play again later.";
                [self personalityGameThrewError];
            }
        } else if ([requestString hasPrefix:@"ioslog"]) {
            if (_loadingGameHud) {
                [_loadingGameHud hide:YES];
                _loadingGameHud = nil;
            }
            NSLog(requestString);

        } else if ([requestString hasPrefix:@"ioserror"]) {
            _messageLabel.text = @"There was an error.";
        }
        return NO;
        // new version
        NSString* jsonString = [[requestString componentsSeparatedByString:@"ios://"] objectAtIndex:1];
        NSDictionary *jsonMessage = [jsonString objectFromJSONString];
        NSString *messageType = jsonMessage[@"type"];
        if ([messageType isEqualToString:@"start"]) {
            [_loadingGameHud hide:YES];
            _loadingGameHud = nil;
        } else if ([messageType isEqualToString:@"finish"]) {
            [self personalityGameFinishedSuccessfully];
        } else if ([messageType isEqualToString:@"log"]) {
            NSLog([NSString stringWithFormat:@"WEB.LOG (message):%@",jsonMessage[@"message"]]);
            NSLog([NSString stringWithFormat:@"WEB.LOG (details):%@",jsonMessage[@"details"]]);
        } else if ([messageType isEqualToString:@"error"]) {
            _messageLabel.text = jsonMessage[@"message"];
            NSLog([NSString stringWithFormat:@"WEB.ERROR (message):%@",jsonMessage[@"message"]]);
            NSLog([NSString stringWithFormat:@"WEB.ERROR (details):%@",jsonMessage[@"details"]]);
            [self personalityGameThrewError];
        } else if ([messageType isEqualToString:@"warn"]) {
            NSLog([NSString stringWithFormat:@"WEB.WARN (message):%@",jsonMessage[@"message"]]);
            NSLog([NSString stringWithFormat:@"WEB.WARN (details):%@",jsonMessage[@"details"]]);
        }
        return NO;
    }
    return YES;
}

-(void)webViewTimedOut
{
    _messageLabel.text = @"Request timed out. Network too slow";
    [_webView removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_timeoutTimer invalidate];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // webView connected
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(webViewTimedOut) userInfo:nil repeats:NO];
}


-(void)startNewPersonalityGame
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.scrollView.bounces = NO;
    NSURLRequest *request = [_oauthClient requestWithMethod:@"get" path:[NSString stringWithFormat:@"#gameForUser/%@", [_oauthClient oauthToken]] parameters:nil];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://dev.tidepool.co.s3-website-us-west-1.amazonaws.com/#gameForUser/%@", [_oauthClient oauthToken]]]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [self.view addSubview:_webView];
    } completion:^(BOOL finished) {
        _loadingGameHud = [MBProgressHUD showHUDAddedTo:_webView animated:YES];
        _loadingGameHud.labelText = @"Loading personality game...";
    }];
    
    // useful for debugging
//    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(testJS) userInfo:nil repeats:NO];
    
}


-(void)testJS
{
    NSString *jsString = @"var iframe = document.createElement('IFRAME');var src = 'ioslog://yepps';iframe.setAttribute('src', src);document.documentElement.appendChild(iframe);";
    NSLog([_webView stringByEvaluatingJavaScriptFromString:jsString]);
}

-(void)personalityGameFinishedSuccessfully
{
    _messageLabel.text = @"Personality Game finished successfully";
    [_oauthClient getUserInfoFromServer];
    [self.delegate personalityGameIsDone:self];
}

-(void)personalityGameThrewError
{
    [_webView removeFromSuperview];
}

-(void)logoutButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [_oauthClient logout];
}

@end
