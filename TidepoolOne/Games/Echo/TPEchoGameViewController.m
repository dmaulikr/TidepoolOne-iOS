//
//  TPEchoGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoGameViewController.h"

@interface TPEchoGameViewController ()

@end

@implementation TPEchoGameViewController

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
    self.type = @"echo";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Echo New Game"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Started Echo"];
#endif
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
