//
//  TPLoginViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLoginViewController.h"
#import "TPAppDelegate.h"
#import "TPOAuthClient.h"
#import "TPServiceLoginViewController.h"
#import "TPGameViewController.h"

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
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    float kPadding = 5;
    float kTextFieldHeight = 30;
    TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, self.view.bounds.size.width - 2*kPadding, 100)];
    topLabel.text = @"Create a free account";
    [self.view addSubview:topLabel];

    TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100, self.view.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
    emailField.placeholder = @"Email address";
    [self.view addSubview:emailField];
    
    self.loginEmail = emailField;
    
    TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100 + kTextFieldHeight - 1, self.view.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
    passwordField.placeholder = @"Password";
    passwordField.secureTextEntry = YES;
    [self.view addSubview:passwordField];

    self.loginPassword = passwordField;
    
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
                            _sharedClient.clientId, @"client_id",
                            _sharedClient.clientSecret, @"client_secret",
                            nil];
    [_sharedClient postPath:@"oauth/authorize" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success");
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        _sharedClient.oauthAccessToken = [responseObject valueForKey:@"access_token"];
        [_sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",_sharedClient.oauthAccessToken]];        
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

- (IBAction)fbLoginButtonPressed:(id)sender {
    TPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate openSessionWithAllowLoginUI:YES];
}

- (IBAction)fitbitLoginButtonPressed:(id)sender {
    TPServiceLoginViewController *loginView = [[TPServiceLoginViewController alloc] init];
    [self presentViewController:loginView animated:YES completion:^{
        NSLog(@"yeah");
    }];
}


@end
