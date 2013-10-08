//
//  TPSettingsViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPSettingsViewController : UITableViewController

- (IBAction)saveButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *leftHandButton;
@property (strong, nonatomic) IBOutlet UIButton *rightHandButton;
@property (strong, nonatomic) IBOutlet UIButton *mixedHandButton;
@property (strong, nonatomic) IBOutlet UIButton *maleButton;
@property (strong, nonatomic) IBOutlet UIButton *femaleButton;

- (IBAction)handButtonPressed:(UIButton *)sender;
- (IBAction)genderButtonPressed:(UIButton *)sender;
- (IBAction)logoutButtonPressed:(id)sender;

@end
