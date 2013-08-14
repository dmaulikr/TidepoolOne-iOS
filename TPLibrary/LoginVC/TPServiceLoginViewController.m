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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.1.10.24:7000/#gameForUser/9e3a202902a518b60914cda7cdadd9f013de35bc1aef9f39374d536140beeaaa"]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(ericJS) userInfo:nil repeats:NO];
}

-(void)ericJS
{
    [_webView stringByEvaluatingJavaScriptFromString:@"alert(JSON.stringify(_app.user.attributes))"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webviewMessageKey:(NSString *)key value:(NSString *)val
{
    NSLog(@"%@:%@",key,val);
    NSLog(@"JS: %@",[_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].innerHTML = 'boo'"]);
}

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    NSLog(requestString);
    
    if ([requestString hasPrefix:@"iosAction:"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@"iosAction://"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", logString);
        return NO;
    }
    
    return YES;
}

@end
