//
//  TPLoginViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface TPLoginViewController : UIViewController

@property (nonatomic, strong) TPBarButtonItem *rightButton;
@property (nonatomic, strong) UIView *currentView;

- (IBAction)fbLoginButtonPressed:(id)sender;

@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) IBOutlet UITextField *loginEmail;
@property (strong, nonatomic) IBOutlet UITextField *loginPassword;
- (IBAction)loginButtonPressed:(id)sender;

@property (strong, nonatomic) UIView *createAccountView;
@property (strong, nonatomic) IBOutlet UITextField *createAccountEmail;
@property (strong, nonatomic) IBOutlet UITextField *createAccountPassword;
@property (strong, nonatomic) IBOutlet UITextField *createAccountPassword2;
- (IBAction)createAccountButtonPressed:(id)sender;

@end