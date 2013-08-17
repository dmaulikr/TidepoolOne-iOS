//
//  TPTabBarController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTabBarController.h"
#import "TPLoginViewController.h"
#import "TPPersonalityGameViewController.h"

@interface TPTabBarController ()
{
    TPOAuthClient *_oauthClient;
    TPLoginViewController *_loginVC;
    TPPersonalityGameViewController *_personalityVC;
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
    _oauthClient = [TPOAuthClient sharedClient];
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
    NSLog(@"checking client online status %i", _oauthClient.isLoggedIn);    
    BOOL success = 0;
    if (_oauthClient.hasOauthToken && !_oauthClient.isLoggedIn) {
        success = [_oauthClient loginPassively];
    }
    if (!_oauthClient.isLoggedIn) {
        _loginVC = [[TPLoginViewController alloc] init];
        [self presentViewController:_loginVC animated:YES completion:^{}];
    }
}

-(void)loggedInSignal
{
    NSLog(@"Tab bar got logged in signal");
    NSLog(@"checking client %i", _oauthClient.isLoggedIn);
    [_loginVC dismissViewControllerAnimated:YES completion:^{
        NSLog(@"oauth %@", [_oauthClient description]);
        NSLog(@"oauth user %@", [_oauthClient.user description]);
        NSDictionary *personality = _oauthClient.user[@"personality"];
        if (!personality || personality == [NSNull null]) {
            _personalityVC = [[TPPersonalityGameViewController alloc] init];
            [self presentViewController:_personalityVC animated:YES completion:^{
            }];
            _loginVC = nil;
        }
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
