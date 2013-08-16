//
//  TPTabBarController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTabBarController.h"
#import "TPLoginViewController.h"

@interface TPTabBarController ()
{
    TPOAuthClient *_oauthClient;
    TPLoginViewController *_loginVC;
}
@end

@implementation TPTabBarController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOutSignal) name:@"Logged Out" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInSignal) name:@"Logged In" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doLogin];
}

-(void)doLogin
{
    NSLog(@"Tab bar is to try and login");
    [[TPOAuthClient sharedClient] loginAndPresentUI:YES onViewController:self withCompletingHandlersSuccess:^{
            NSLog(@"Tab bar user %@",[[[TPOAuthClient sharedClient] user] description]);
    } andFailure:^{
    }];
}

-(void)loggedInSignal
{
    NSLog(@"Tab bar got logged in signal");
    [_loginVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)loggedOutSignal
{
    NSLog(@"Tab bar got logged out signal");
    [self doLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
