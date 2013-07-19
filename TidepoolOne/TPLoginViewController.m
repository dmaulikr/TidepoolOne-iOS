//
//  TPLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLoginViewController.h"
#import "TPOAuthClient.h"
#import "TPReactionTimeGameViewController.h"

@interface TPLoginViewController ()
{
    TPOAuthClient *_sharedClient;
}
@end

@implementation TPLoginViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)login
{
    _sharedClient = [TPOAuthClient sharedClient];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type",
                            @"password", @"response_type",
                            self.loginEmail.text, @"email",
                            self.loginPassword.text, @"password",
                            @"3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1", @"client_id",
                            @"3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706", @"client_secret",
                            nil];
    [_sharedClient postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        [_sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",_sharedClient.oauthAccessToken]];
        
        [_sharedClient postPath:@"api/v1/users/-/games?def_id=reaction_time" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            NSDictionary *dict = responseObject;
            TPReactionTimeGameViewController *gameVC = [self.tabBarController.viewControllers objectAtIndex:1];
            gameVC.response = responseObject;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure");
            NSLog([error description]);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        NSLog([error description]);
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self login];
    [self resignFirstResponder];
    [self.view endEditing:YES];
}
@end
