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

@property (weak, nonatomic) IBOutlet UITextField *loginEmail;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)fbLoginButtonPressed:(id)sender;
- (IBAction)fitbitLoginButtonPressed:(id)sender;

@end
