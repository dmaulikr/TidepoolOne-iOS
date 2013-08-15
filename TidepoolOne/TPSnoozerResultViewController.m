//
//  TPSnoozerResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultViewController.h"
#import "TPLocalNotificationManager.h"

@interface TPSnoozerResultViewController ()

@end

@implementation TPSnoozerResultViewController

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
    self.title = @"Snoozer Results";
    if (self.navigationController) {
        self.navBar.hidden = YES;
        self.bottomBar.hidden = YES;
        self.playAgainButton.hidden = YES;
        self.nextButton.hidden = YES;
//        CGRect scrollRect = self.scrollView.frame;
//        scrollRect.size.height += self.bottomBar.frame.size.height;
        self.scrollView.bounds = self.view.bounds;
    }
    self.history = @[@220, @270, @230, @250];
    
    [[TPLocalNotificationManager sharedInstance] createNotification];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"results-bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
