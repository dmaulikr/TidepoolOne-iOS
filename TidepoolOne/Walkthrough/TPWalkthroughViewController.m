//
//  TPWalkthroughViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/26/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPWalkthroughViewController.h"
#import <LAWalkthrough/LAWalkthroughViewController.h>

@interface TPWalkthroughViewController ()
{
    UIButton *_dismissButton;
}
@end

@implementation TPWalkthroughViewController

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
    LAWalkthroughViewController *walkthrough = [[LAWalkthroughViewController alloc] init];
    walkthrough.view.frame = self.view.bounds;
    walkthrough.nextButtonText = @"";
    
    int numImages = 5;
    for (int i=0;i <numImages; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tp-appwalkthrough%i.jpg",i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [walkthrough addPageWithView:imageView];
    }
    [self addChildViewController:walkthrough];
    [self.view addSubview:walkthrough.view];
    
    
    _dismissButton = [[UIButton alloc] initWithFrame:CGRectZero];
    UIImage *xImage = [UIImage imageNamed:@"btn-xclose.png"];
    [_dismissButton setBackgroundImage:xImage forState:UIControlStateNormal];
    _dismissButton.frame = CGRectMake(self.view.bounds.size.width - xImage.size.width, 0, xImage.size.width, xImage.size.height);
    [_dismissButton addTarget:self action:@selector(quitWalkthrough) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Walkthrough Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Walkthrough shown"];
#endif    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)quitWalkthrough
{
    [self.view removeFromSuperview];
    [self willMoveToParentViewController:nil];
    [self removeFromParentViewController];
}


@end
