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
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:186/255.0 blue:60/255.0 alpha:1.0];
	// Do any additional setup after loading the view.
    // Send a screen view to the first property.
    id tracker1 = [[GAI sharedInstance] trackerWithTrackingId:@"UA-43075789-1"];
    [tracker1 sendView:@"/SnoozerGame"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOutSignal) name:@"Logged Out" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInSignal) name:@"Logged In" object:nil];
    self.type = @"snoozer";
    self.type = @"snoozers"; //For debugging
}

- (void)viewDidAppear:(BOOL)animated
{
}

-(void)loggedInSignal
{
//    [self getNewGame];
}


-(void)loggedOutSignal
{
    for (UIViewController *child in super.childViewControllers) {
        [super hideContentController:child];
    }
    self.gameStartView.hidden = NO;
}

-(void)learnMore
{
    [self performSegueWithIdentifier:@"learnMoreSegue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (IBAction)playButtonPressed:(id)sender {
    [self getNewGame];
}
@end
