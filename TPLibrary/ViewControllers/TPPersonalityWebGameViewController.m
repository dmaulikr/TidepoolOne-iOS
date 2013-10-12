//
//  TPPersonalityWebGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPersonalityWebGameViewController.h"

@interface TPPersonalityWebGameViewController ()
{
    UIWebView *_webView;
    TPLabel *_messageLabel;
}
@end

@implementation TPPersonalityWebGameViewController

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
	// Do any additional setup after loading the view.
    
    _messageLabel = [[TPLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    _messageLabel.text = @"Messages go here";
    [self.view addSubview:_messageLabel];
    
    TPButton *playAgainButton = [[TPButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [playAgainButton setTitle:@"Play again" forState:UIControlStateNormal];
    [playAgainButton addTarget:self action:@selector(startNewPersonalityGame) forControlEvents:UIControlEventTouchUpInside];
    playAgainButton.center = CGPointMake(self.view.bounds.size.width/2, 400);
    [self.view addSubview:playAgainButton];
}

-(void)startNewPersonalityGame
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://tide-dev.herokuapp.com/#gameForUser/b035b21b813bc54290b7f4b39ea93dbeff6be3f207923fbb3321d2894a359344"]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^ {
                            [self.view addSubview:_webView];
                    }
                    completion:nil];


    
}



- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    requestString = [requestString lowercaseString];
    
    if ([requestString hasPrefix:@"iosaction"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@"iosaction://"] objectAtIndex:1];
        BOOL done = logString.boolValue;
        if (done) {
            [self personalityGameFinishedSuccessfully];
        } else {
            [self personalityGameThrewError];
        }
        
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)personalityGameFinishedSuccessfully
{
    [_webView removeFromSuperview];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)personalityGameThrewError
{
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^ {
                        [_webView removeFromSuperview];
                    }
                    completion:nil];
    _messageLabel.text = @"There was an error with the game. Please try again";
}

@end
