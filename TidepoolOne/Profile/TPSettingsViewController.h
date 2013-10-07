//
//  TPSettingsViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPSettingsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet TPTextField *name;
@property (strong, nonatomic) IBOutlet TPTextField *email;
@property (strong, nonatomic) IBOutlet TPTextField *age;
@property (strong, nonatomic) IBOutlet TPTextField *education;
@property (strong, nonatomic) IBOutlet NSString *handedness;
@property (strong, nonatomic) IBOutlet NSString *gender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

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
