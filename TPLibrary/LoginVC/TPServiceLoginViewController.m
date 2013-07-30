//
//  TPServiceLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPServiceLoginViewController.h"
#import "NSObject+SEWebviewJSListener.h"

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:4567/hello.html"]];
    [_webView loadRequest:request];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
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

@end
