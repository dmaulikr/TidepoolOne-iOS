//
//  TPPersonalityGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPersonalityGameViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SBJson/SBJson.h>
#import "TPLabel.h"
#import "TPOAuthClient.h"
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>


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
    button.center = CGPointMake(1*self.view.bounds.size.width/2, 325);
    [button setTitle:@"Logout" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [[TPButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/3, 50)];
    button.center = CGPointMake(3*self.view.bounds.size.width/4, 250);
    [button setTitle:@"Play Later" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playLaterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self startNewPersonalityGame];

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
    
//    NSLog(@"FromWebView: %@", requestString);
    
    if ([requestString hasPrefix:@"ios"]) {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
         NSString* jsonString = [[requestString componentsSeparatedByString:@"ios://"] objectAtIndex:1];
        NSDictionary *jsonMessage = [jsonParser objectWithString:jsonString];
        NSString *messageType = jsonMessage[@"type"];
        if ([messageType isEqualToString:@"start"]) {
            [_loadingGameHud hide:YES];
            _loadingGameHud = nil;
        } else if ([messageType isEqualToString:@"finish"]) {
            [self personalityGameFinishedSuccessfully];
        } else if ([messageType isEqualToString:@"log"]) {
            NSLog(@"WEB.LOG (message):%@",jsonMessage[@"message"]);
            NSLog(@"WEB.LOG (details):%@",jsonMessage[@"details"]);
            [self logEventToGoogleAnalytics:jsonMessage[@"message"] ofType:@"log"];
#ifndef DEBUG
            //Analytics
            [[Mixpanel sharedInstance] track:jsonMessage[@"message"]];
#endif
        } else if ([messageType isEqualToString:@"error"]) {
            _messageLabel.text = jsonMessage[@"message"];
            NSLog(@"WEB.ERROR (message):%@",jsonMessage[@"message"]);
            NSLog(@"WEB.ERROR (details):%@",jsonMessage[@"details"]);
            [self logEventToGoogleAnalytics:jsonMessage[@"message"] ofType:@"error"];
#ifndef DEBUG
            //Analytics
            [[Mixpanel sharedInstance] track:jsonMessage[@"message"]];
#endif
            [self personalityGameThrewError];
        } else if ([messageType isEqualToString:@"warn"]) {
            NSLog(@"WEB.WARN (message):%@",jsonMessage[@"message"]);
            NSLog(@"WEB.WARN (details):%@",jsonMessage[@"details"]);
            [self logEventToGoogleAnalytics:jsonMessage[@"message"] ofType:@"warn"];
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
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Personality Game Started"];
#endif
    _webView = [[UIWebView alloc] init];
    _webView.scrollView.bounces = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // normal comportment
        _webView.frame = self.view.bounds;
    } else {
        _webView.frame = CGRectMake(0, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20);
        }
    NSURL *localUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"Personality Game/dist"]];
    
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://alpha.tidepool.co/#gameForUser/%@", [_oauthClient oauthToken]]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@#gameForUser/%@", localUrl, [_oauthClient oauthToken]]]];

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
//    NSString *jsString = @"var iframe = document.createElement('IFRAME');var src = 'ioslog://yepps';iframe.setAttribute('src', src);document.documentElement.appendChild(iframe);";
//    NSLog([_webView stringByEvaluatingJavaScriptFromString:jsString]);
}

-(void)personalityGameFinishedSuccessfully
{
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Personality Game Success"];
#endif
    _messageLabel.text = @"Personality Game finished successfully";
    [_oauthClient forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:^(NSDictionary *user) {
    } andFailure:^{
    }];
    [self.delegate personalityGameIsDone:self successfully:YES];
}

-(void)personalityGameThrewError
{
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Personality Game Error"];
#endif
    [_webView removeFromSuperview];
    _webView = nil;
}

-(void)logoutButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [_oauthClient logout];
}

-(void)playLaterButtonPressed
{
    [self.delegate personalityGameIsDone:self successfully:NO];
}

-(void)logEventToGoogleAnalytics:(NSString *)event ofType:(NSString *)type
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"personality_game"     // Event category (required)
                                                          action:type  // Event action (required)
                                                           label:event          // Event label
                                                           value:nil] build]];    // Event value
}


@end
