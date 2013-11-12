//
//  TPWebViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/8/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPWebViewController.h"

@interface TPWebViewController ()

@end

@implementation TPWebViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.webView loadRequest:_request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
