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
    // Send a screen view to the first property.
    id tracker1 = [[GAI sharedInstance] trackerWithTrackingId:@"UA-43075789-1"];
    [tracker1 sendView:@"/SnoozerGame"];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    self.type = @"snoozer";
    if (![[TPOAuthClient sharedClient] isLoggedIn]) {
        NSLog(@"SnoozerGame considers not logged in");
        [[TPOAuthClient sharedClient] loginAndPresentUI:YES onViewController:self withCompletingHandlersSuccess:^{
            [self startNewGame];
        } andFailure:^{
        }];        
    } else {
        [self startNewGame];        
        NSLog(@"SnoozerGame considers logged in");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
