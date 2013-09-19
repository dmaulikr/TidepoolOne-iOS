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
#import <MBProgressHUD/MBProgressHUD.h>
#import "TPPersonalityGameViewController.h"
#import "TPWalkthroughViewController.h"


@interface TPLoginViewController ()
{
    TPOAuthClient *_sharedClient;
    MBProgressHUD *_progressView;
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _sharedClient = [TPOAuthClient sharedClient];
    kPadding = 10;
    kTextFieldHeight = 40;
    kVerticalOffset = 175;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError) name:@"OAuthClient error" object:nil];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImage.image = [UIImage imageNamed:@"login.png"];
    [self.view addSubview:backgroundImage];

    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    navBar.frame = CGRectMake(0,0,self.view.bounds.size.width,44);
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"TidePool";
    _rightButton = [[TPBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(flip)];
    navItem.rightBarButtonItem = _rightButton;
    [navBar pushNavigationItem:navItem animated:NO];
    [self.view addSubview:navBar];
    
    self.currentView = self.createAccountView;
    [self.view addSubview:self.createAccountView];
    
    [self setupKeyboardHandlers];
    //Show walkthrough on first run
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"WalkthroughShown"]) {
        // Delete values from keychain here
        [self showWalkthrough];
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"WalkthroughShown"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Login Screen"];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        // Load resources for iOS 7 or later
        self.view.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 40);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard handlers

-(void)setupKeyboardHandlers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionChanged:) name:@"com.TidePool.TidepoolOne:FBSessionStateChangedNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];    
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectOffset(self.view.frame, 0, -160);
    }];
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectOffset(self.view.frame, 0, 160);
    }];
    
}

-(void)dismissKeyboard {
    [self.loginEmail resignFirstResponder];
    [self.loginPassword resignFirstResponder];
    [self.createAccountEmail resignFirstResponder];
    [self.createAccountPassword resignFirstResponder];
    [self.createAccountPassword2 resignFirstResponder];
}


-(void)handleError
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)showWalkthrough
{
    // Create the walkthrough view controller
    TPWalkthroughViewController *walkthrough = [[TPWalkthroughViewController alloc] init];
    walkthrough.view.frame = self.view.bounds;
    [self addChildViewController:walkthrough];
    [walkthrough didMoveToParentViewController:self];
    [self.view addSubview:walkthrough.view];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark LoginView

- (UIView *)loginView
{
    if (!_loginView) {
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _loginView.bounds.size.width - 2*kPadding, kVerticalOffset - 95)];
        topLabel.text = @"Welcome back!";
        topLabel.centered = YES;
        [_loginView addSubview:topLabel];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"email address";
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        [_loginView addSubview:emailField];
        
        self.loginEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + kTextFieldHeight - 1, _loginView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"password";
        passwordField.secureTextEntry = YES;
        [_loginView addSubview:passwordField];
        
        self.loginPassword = passwordField;
        
        [self addFacebookLoginButtonToView:_loginView];
        
        TPButton *loginButton = [TPButton buttonWithType:UIButtonTypeCustom];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
        loginButton.frame = CGRectMake(0, 0, 300, 45);
        loginButton.center = CGPointMake(self.view.center.x, kVerticalOffset + 125);
        
        [loginButton setTitle:@"Get started" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:loginButton];
        
    }
    return _loginView;
}

- (IBAction)loginButtonPressed:(id)sender {
    _progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressView.labelText = @"Logging In";
    [_sharedClient loginWithUsername:self.loginEmail.text password:self.loginPassword.text withCompletingHandlersSuccess:^{
    } andFailure:^{
        [self handleError];
    }];
    [self resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark CreateAccountView

- (UIView *)createAccountView
{
    if (!_createAccountView) {
        _createAccountView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        TPLabel *topLabel = [[TPLabel alloc] initWithFrame:CGRectMake(kPadding, 0, _createAccountView.bounds.size.width - 2*kPadding, kVerticalOffset - 95)];
        topLabel.text = @"Create a free account";
        topLabel.centered = YES;
        [_createAccountView addSubview:topLabel];
        
        [self addFacebookLoginButtonToView:_createAccountView];
        
        TPTextField *emailField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        emailField.placeholder = @"email address";
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [_createAccountView addSubview:emailField];
        
        self.createAccountEmail = emailField;
        
        TPTextField *passwordField = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + kTextFieldHeight - 1, _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField.placeholder = @"password";
        passwordField.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField];
        
        TPTextField *passwordField2 = [[TPTextField alloc] initWithFrame:CGRectMake(kPadding, kVerticalOffset + 2*(kTextFieldHeight - 1), _createAccountView.bounds.size.width - 2 * kPadding, kTextFieldHeight)];
        passwordField2.placeholder = @"confirm password";
        passwordField2.secureTextEntry = YES;
        [_createAccountView addSubview:passwordField2];
        
        self.createAccountPassword = passwordField;
        self.createAccountPassword2 = passwordField2;
        
        TPButton *createAccountButton = [TPButton buttonWithType:UIButtonTypeCustom];
        [createAccountButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
        createAccountButton.frame = CGRectMake(0, 0, 300, 45);
        createAccountButton.center = CGPointMake(self.view.center.x, kVerticalOffset + 165);
        [createAccountButton setTitle:@"Create account" forState:UIControlStateNormal];
        [createAccountButton addTarget:self action:@selector(createAccountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_createAccountView addSubview:createAccountButton];
        
        
    }
    return _createAccountView;
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
    _progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressView.labelText = @"Creating User...";
    [_sharedClient createAccountWithUsername:self.createAccountEmail.text password:self.createAccountPassword.text withCompletingHandlersSuccess:^{
        [_progressView hide:YES];
    } andFailure:^{
        [_progressView hide:YES];
        [[[UIAlertView alloc] initWithTitle:@"Server error" message:@"Error on the server" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
    }];
}


-(void)facebookSessionChanged:(id)sender
{
    FBSession *session = [sender object];
    switch (session.state) {
        case FBSessionStateOpen:
            
            break;
        case FBSessionStateClosed:
            [FBSession.activeSession closeAndClearTokenInformation];            
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an unknown error authorizing through facebook." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
            [self handleError];
            break;
        default:
            break;
    }
}

#pragma mark 2-View Management

-(void) setCurrentView:(UIView *)currentView
{
    _currentView = currentView;
    if (currentView == self.loginView) {
        self.rightButton.title = @"Sign up";
    } else {
        self.rightButton.title = @"Log in";
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

#pragma mark Common Actions

- (IBAction)fbLoginButtonPressed:(id)sender {
    _progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressView.labelText = @"Logging In";
    TPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate openSessionWithAllowLoginUI:YES completionHandlersSuccess:^{
        NSLog(@"fb login complete");
    } andFailure:^{
        [self handleError];
    }];
}

-(void)addFacebookLoginButtonToView:(UIView *)view
{
    TPButton *facebookButton = [TPButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setBackgroundImage:[UIImage imageNamed:@"btn-facebook.png"] forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(0, 0, 300, 45);
    facebookButton.center = CGPointMake(self.view.center.x, kVerticalOffset - 95);
    [facebookButton setTitle:@"   Log in with Facebook" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(fbLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:facebookButton];
    [self addOrGraphicToView:view];
}

-(void)addOrGraphicToView:(UIView *)view
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 227, 37)];
    imgView.center = CGPointMake(self.view.center.x, kVerticalOffset - 35);
    imgView.image = [UIImage imageNamed:@"or-graphic.png"];
    [view addSubview:imgView];
}


@end
