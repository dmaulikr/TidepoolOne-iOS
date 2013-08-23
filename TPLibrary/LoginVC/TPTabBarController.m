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
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPTabBarController ()
{
    TPOAuthClient *_oauthClient;
    TPLoginViewController *_loginVC;
    TPPersonalityGameViewController *_personalityVC;
    UIImageView *_tooltipView;
    NSTimer *_tooltipTimer;
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
    
    if (_loginVC) {
        [_loginVC dismissViewControllerAnimated:YES completion:^{
            [self showPersonalityGame];
        }];
    } else {
        [self showPersonalityGame];        
    }
}

-(void)showPersonalityGame
{
    if (!_oauthClient.user) { //for cases when oauthclient is still loading user data
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading Personality...";
        [_oauthClient getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            _oauthClient.user = responseObject[@"data"];
            NSDictionary *personality = _oauthClient.user[@"personality"];
            if (!personality || personality == [NSNull null]) {
                _personalityVC = [[TPPersonalityGameViewController alloc] init];
                [self presentViewController:_personalityVC animated:YES completion:^{
                }];
                _loginVC = nil;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            [_oauthClient handleError:error withOptionalMessage:@"Unable to get user information"];
        }];
    } else {
        NSDictionary *personality = _oauthClient.user[@"personality"];
        if (!personality || personality == [NSNull null]) {
            _personalityVC = [[TPPersonalityGameViewController alloc] init];
            [self presentViewController:_personalityVC animated:YES completion:^{
            }];
            _personalityVC.delegate = self;
            _loginVC = nil;
        }
    }
}



-(void)loggedOutSignal
{
    NSLog(@"Tab bar got logged out signal");
    [self doLogin];
}

-(void)personalityGameIsDone:(id)sender
{
    NSLog(@"personality done delegate method called on tabbar");
    UIViewController *vc = sender;
    [vc dismissViewControllerAnimated:YES completion:^{
        self.selectedIndex = 2;
        [self showTooltip];
    }];
}

-(void)showTooltip
{
    UIImage *image = [UIImage imageNamed:@"playsnoozer-alertb.png"];
    // TODO : calculate position correctly... 
    _tooltipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - self.tabBar.bounds.size.height - image.size.height, image.size.width, image.size.height)];
    _tooltipView.image = image;
    [self.view addSubview:_tooltipView];
    _tooltipTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismissTooltip) userInfo:nil repeats:NO];
}

-(void)dismissTooltip
{
    [_tooltipTimer invalidate];
    _tooltipTimer = nil;
    [UIView animateWithDuration:1.0 animations:^{
        _tooltipView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_tooltipView removeFromSuperview];
        _tooltipView = nil;
    }];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self dismissTooltip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
