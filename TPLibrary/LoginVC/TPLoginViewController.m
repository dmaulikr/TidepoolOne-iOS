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
    
    [self.view addSubview:self.loginView];
    
//    [UIView transitionFromView:self.createAccountView toView:self.loginView duration:20.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {}];
    
}
- (UIView *)createAccountView
{
    if (!_createAccountView) {
        _createAccountView = [[UIView alloc] initWithFrame:self.view.bounds];
        float kPadding = 5;
        float kTextFieldHeight = 30;
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _createAccountView.bounds.size.width - 2*kPadding, 100)];
        topLabel.text = @"Create a free account";
        [_createAccountView addSubview:topLabel];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"Email address";
        [_createAccountView addSubview:emailField];
        
        self.createAccountEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100 + kTextFieldHeight - 1, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"Password";
        passwordField.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField];

        TPTextField *passwordField2 = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100 + 2*(kTextFieldHeight - 1), _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField2.placeholder = @"Password";
        passwordField2.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField2];
        
        self.createAccountPassword = passwordField;
        self.createAccountPassword2 = passwordField2;
        
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        facebookButton.frame = CGRectMake(kPadding, 200, 100, 20);
        [facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(fbLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_createAccountView addSubview:facebookButton];
        
        UIButton *createAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        createAccountButton.frame = CGRectMake(150, 200, 100, 20);
        [createAccountButton setTitle:@"Create account" forState:UIControlStateNormal];
        [createAccountButton addTarget:self action:@selector(createAccountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_createAccountView addSubview:createAccountButton];


    }
    return _createAccountView;
}

- (UIView *)loginView
{
    if (!_loginView) {
        _loginView = [[UIView alloc] initWithFrame:self.view.bounds];
        float kPadding = 5;
        float kTextFieldHeight = 30;
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _loginView.bounds.size.width - 2*kPadding, 100)];
        topLabel.text = @"Welcome back!";
        [_loginView addSubview:topLabel];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"Email address";
        [_loginView addSubview:emailField];
        
        self.loginEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, 100 + kTextFieldHeight - 1, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"Password";
        passwordField.secureTextEntry = YES;
        [_loginView addSubview:passwordField];
        
        self.loginPassword = passwordField;
        
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        facebookButton.frame = CGRectMake(kPadding, 200, 100, 20);
        [facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(fbLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_createAccountView addSubview:facebookButton];

        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.frame = CGRectMake(150, 200, 100, 20);
        [loginButton setTitle:@"Get started" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:loginButton];
        
    }
    return _loginView;
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
        [self dismissViewControllerAnimated:YES completion:^{}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        NSLog([error description]);
    }];
}

- (IBAction)createAccountButtonPressed:(id)sender
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
        [self dismissViewControllerAnimated:YES completion:^{}];
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
