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

    int numImages = 5;
    for (int i=0;i <numImages; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tp-appwalkthrough%i.jpg",i+1]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [walkthrough addPageWithView:imageView];
    }    
    [self addChildViewController:walkthrough];
    [self.view addSubview:walkthrough.view];
    
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, self.view.bounds.size.height - 90, 200, 40)];
    [dismissButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
    [dismissButton setTitle:@"Get Started!" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(quitWalkthrough) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
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
