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
    _sharedClient = [TPOAuthClient sharedClient];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Default.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.frame = CGRectMake(0,0,self.view.bounds.size.width,44);
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"Welcome To Tidepool";
    _rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(flip)];
    navItem.rightBarButtonItem = _rightButton;
    [navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:navBar];
    
    self.currentView = self.loginView;
    [self.view addSubview:self.loginView];
}

-(void) setCurrentView:(UIView *)currentView
{
    _currentView = currentView;
    if (currentView == self.loginView) {
        self.rightButton.title = @"Create account";
    } else {
        self.rightButton.title = @"Login";        
    }
}

-(void) flip
{
    UIView *newView;
    UIViewAnimationOptions animationOptions;
    if (self.currentView == self.loginView) {
        newView = self.createAccountView;
        animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
    } else {
        newView = self.loginView;
        animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
    }
    [UIView transitionFromView:self.currentView toView:newView duration:0.5 options:animationOptions completion:^(BOOL finished) {
        self.currentView = newView;
    }];
    NSLog(@"fuck");
}


- (UIView *)createAccountView
{
    if (!_createAccountView) {
        _createAccountView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
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
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
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
        [_loginView addSubview:facebookButton];

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


- (IBAction)createAccountButtonPressed:(id)sender
{
}

- (IBAction)loginButtonPressed:(id)sender {
    [_sharedClient loginWithUsername:self.loginEmail.text password:self.loginPassword.text withCompletingHandlersSuccess:^{
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } andFailure:^{
    }];
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
