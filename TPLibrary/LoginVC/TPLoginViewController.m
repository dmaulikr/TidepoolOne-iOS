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
    float kPadding;
    float kTextFieldHeight;
    float kVerticalOffset;
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
    kPadding = 5;
    kTextFieldHeight = 35;
    kVerticalOffset = 195;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoginSignal) name:@"Logged In" object:nil];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImage.image = [UIImage imageNamed:@"Default.png"];
    [self.view addSubview:backgroundImage];

    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.frame = CGRectMake(0,0,self.view.bounds.size.width,44);
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"Welcome";
    _rightButton = [[TPBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(flip)];
    navItem.rightBarButtonItem = _rightButton;
    [navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:navBar];
    
    self.currentView = self.loginView;
    [self.view addSubview:self.loginView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionChanged:) name:@"com.TidePool.TidepoolOne:FBSessionStateChangedNotification" object:nil];
    
}

-(void)facebookSessionChanged:(id)sender
{
    FBSession *session = [sender object];
    switch (session.state) {
        case FBSessionStateOpen:
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
        case FBSessionStateClosed:
            [FBSession.activeSession closeAndClearTokenInformation];            
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an unknown error authorizing through facebook." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
            break;
        default:
            break;
    }
}

-(void) setCurrentView:(UIView *)currentView
{
    _currentView = currentView;
    if (currentView == self.loginView) {
        self.rightButton.title = @"Create";
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
}


- (UIView *)createAccountView
{
    if (!_createAccountView) {
        _createAccountView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _createAccountView.bounds.size.width - 2*kPadding, 100)];
        topLabel.text = @"Create a free account";
        topLabel.centered = YES;
        [_createAccountView addSubview:topLabel];
        
        [self addFacebookLoginButtonToView:_createAccountView];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"Email address";
        [_createAccountView addSubview:emailField];
        
        self.createAccountEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + kTextFieldHeight - 1, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"Password";
        passwordField.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField];

        TPTextField *passwordField2 = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + 2*(kTextFieldHeight - 1), _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField2.placeholder = @"Password";
        passwordField2.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField2];
        
        self.createAccountPassword = passwordField;
        self.createAccountPassword2 = passwordField2;

        UIButton *createAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [createAccountButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
        createAccountButton.frame = CGRectMake(0, 0, 150, 40);
        createAccountButton.center = CGPointMake(self.view.center.x, kVerticalOffset + 165);
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
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _loginView.bounds.size.width - 2*kPadding, 100)];
        topLabel.text = @"Welcome back!";
        topLabel.centered = YES;
        [_loginView addSubview:topLabel];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"Email address";
        [_loginView addSubview:emailField];
        
        self.loginEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + kTextFieldHeight - 1, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"Password";
        passwordField.secureTextEntry = YES;
        [_loginView addSubview:passwordField];
        
        self.loginPassword = passwordField;
        
        [self addFacebookLoginButtonToView:_loginView];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
        loginButton.frame = CGRectMake(0, 0, 100, 40);
        loginButton.center = CGPointMake(self.view.center.x, kVerticalOffset + 125);

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
    if (![self.createAccountPassword.text isEqualToString:self.createAccountPassword2.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Password error" message:@"Passwords do not match" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
        return;
    } else if (self.createAccountPassword.text.length < 8) {
        [[[UIAlertView alloc] initWithTitle:@"Password error" message:@"Passwords must be 8 or more characters in length" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
        return;
    }
    [_sharedClient createAccountWithUsername:self.createAccountEmail.text password:self.createAccountPassword.text withCompletingHandlersSuccess:^{
        [self dismissViewControllerAnimated:YES completion:^{}];
    } andFailure:^{
        [[[UIAlertView alloc] initWithTitle:@"Server error" message:@"Error on the server" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
    }];
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
    [delegate openSessionWithAllowLoginUI:YES completionHandlersSuccess:^{
        [self dismissViewControllerAnimated:YES completion:^{}];
    } andFailure:^{
    }];
}

- (IBAction)fitbitLoginButtonPressed:(id)sender {
    TPServiceLoginViewController *loginView = [[TPServiceLoginViewController alloc] init];
    [self presentViewController:loginView animated:YES completion:^{
        NSLog(@"yeah");
    }];
}

-(void)dismissKeyboard {
    [self.loginEmail resignFirstResponder];
    [self.loginPassword resignFirstResponder];
    [self.createAccountEmail resignFirstResponder];
    [self.createAccountPassword resignFirstResponder];
    [self.createAccountPassword2 resignFirstResponder];
}

-(void)addFacebookLoginButtonToView:(UIView *)view
{    
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(0, 0, 200, 40);
    facebookButton.center = CGPointMake(self.view.center.x, 100);
    [facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(fbLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:facebookButton];

}

-(void)receivedLoginSignal
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
