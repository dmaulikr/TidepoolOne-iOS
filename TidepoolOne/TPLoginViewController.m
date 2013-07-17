//
//  TPLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLoginViewController.h"
#import "TPOAuthClient.h"
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
                            @"773cc7e7690e0f541cfc81a9d6df50721c520086bfc63460b5339747b0531cbc", @"client_id",
                            @"b2e891c55531e121b9367e16ea7dde7ad9071399b1e554ead9550ec1858bb782", @"client_secret",
                            nil];
    [_sharedClient postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        [_sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",_sharedClient.oauthAccessToken]];
        
        [_sharedClient postPath:@"api/v1/users/-/games?def_id=reaction_time" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
            NSDictionary *dict = responseObject;
            NSLog([dict[@"stages"][2] description]);
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
