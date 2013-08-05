//
//  TPLoginViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/16/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol TPLoginViewControllerDelegate

@end

@interface TPLoginViewController : UIViewController

@property (nonatomic, strong) UIBarButtonItem *rightButton;
@property (nonatomic, strong) UIView *currentView;

@property (strong, nonatomic) IBOutlet UITextField *loginEmail;
@property (strong, nonatomic) IBOutlet UITextField *loginPassword;

@property (strong, nonatomic) IBOutlet UITextField *createAccountEmail;
@property (strong, nonatomic) IBOutlet UITextField *createAccountPassword;
@property (strong, nonatomic) IBOutlet UITextField *createAccountPassword2;

@property (strong, nonatomic) UIView *createAccountView;
@property (strong, nonatomic) UIView *loginView;


- (IBAction)createAccountButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)fbLoginButtonPressed:(id)sender;
- (IBAction)fitbitLoginButtonPressed:(id)sender;

@end
