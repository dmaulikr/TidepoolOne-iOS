//
//  TPServiceLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPServiceLoginViewController.h"

@interface TPServiceLoginViewController ()
{
    UIWebView *_webView;
}
@end

@implementation TPServiceLoginViewController

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
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://tide-dev.herokuapp.com/#gameForUser/b035b21b813bc54290b7f4b39ea93dbeff6be3f207923fbb3321d2894a359344"]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
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
