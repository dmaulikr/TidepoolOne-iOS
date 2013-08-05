//
//  TPSnoozerGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerGameViewController.h"
#import "TPLoginViewController.h"
#import "TPOAuthClient.h"

@interface TPSnoozerGameViewController ()

@end

@implementation TPSnoozerGameViewController

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
}
- (void)viewDidAppear:(BOOL)animated
{
    [[TPOAuthClient sharedClient] loginAndPresentUI:YES onViewController:self withCompletingHandlersSuccess:^{
        [self startNewGame];
    } andFailure:^{
    }];
    self.type = @"snoozer";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
