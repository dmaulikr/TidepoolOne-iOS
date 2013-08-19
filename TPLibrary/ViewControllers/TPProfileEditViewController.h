//
//  TPProfileEditViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPProfileEditViewController : UIViewController

@property (strong, nonatomic) IBOutlet TPTextField *name;
@property (strong, nonatomic) IBOutlet TPTextField *email;
@property (strong, nonatomic) IBOutlet TPTextField *age;
@property (strong, nonatomic) IBOutlet TPTextField *education;
@property (strong, nonatomic) IBOutlet NSString *handedness;
@property (strong, nonatomic) IBOutlet NSString *gender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)saveButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *leftHandButton;
@property (weak, nonatomic) IBOutlet UIButton *rightHandButton;
@property (weak, nonatomic) IBOutlet UIButton *mixedHandButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;

- (IBAction)handButtonPressed:(UIButton *)sender;
- (IBAction)genderButtonPressed:(UIButton *)sender;

@end
