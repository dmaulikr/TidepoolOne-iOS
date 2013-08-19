//
//  TPProfileEditViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPProfileEditViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPProfileEditViewController ()
{
    TPOAuthClient *_oauthClient;
}
@end

@implementation TPProfileEditViewController

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
    _oauthClient = [TPOAuthClient sharedClient];
	// Do any additional setup after loading the view.
    [_maleButton setImage:[UIImage imageNamed:@"male.png"] forState:UIControlStateNormal];
    [_maleButton setImage:[UIImage imageNamed:@"male-pressed.png"] forState:UIControlStateSelected];
    [_femaleButton setImage:[UIImage imageNamed:@"female.png"] forState:UIControlStateNormal];
    [_femaleButton setImage:[UIImage imageNamed:@"female-pressed.png"] forState:UIControlStateSelected];
    [_rightHandButton setImage:[UIImage imageNamed:@"righthand.png"] forState:UIControlStateNormal];
    [_rightHandButton setImage:[UIImage imageNamed:@"righthand-pressed.png"] forState:UIControlStateSelected];
    [_leftHandButton setImage:[UIImage imageNamed:@"lefthand.png"] forState:UIControlStateNormal];
    [_leftHandButton setImage:[UIImage imageNamed:@"lefthand-pressed.png"] forState:UIControlStateSelected];
    [_mixedHandButton setImage:[UIImage imageNamed:@"mixedhand.png"] forState:UIControlStateNormal];
    [_mixedHandButton setImage:[UIImage imageNamed:@"mixedhand-pressed.png"] forState:UIControlStateSelected];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor colorWithWhite:125.0/255.0 alpha:1.0];
    float kPadding = 10;
    float leftMargin = 120;
    float leftMarginLabel = 10;
    float labelWidth = 100;
    float textFieldHeight = 25;
    float textFieldWidth = 170;
    TPLabel *nameLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding, labelWidth, textFieldHeight)];
    nameLabel.text = @"Name";
    [self.scrollView addSubview:nameLabel];
    self.name = [[TPTextField alloc] initWithFrame:CGRectMake(leftMargin, kPadding, textFieldWidth, textFieldHeight)];
    [self.scrollView addSubview:self.name];
    
    TPLabel *emailLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + (textFieldHeight + kPadding), labelWidth, textFieldHeight)];
    emailLabel.text = @"Email";
    [self.scrollView addSubview:emailLabel];
    self.email = [[TPTextField alloc] initWithFrame:CGRectMake(leftMargin, kPadding + (textFieldHeight + kPadding), textFieldWidth, textFieldHeight)];
    [self.scrollView addSubview:self.email];
    
    TPLabel *ageLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + 2*(textFieldHeight + kPadding), labelWidth, textFieldHeight)];
    ageLabel.text = @"Age";
    [self.scrollView addSubview:ageLabel];
    self.age = [[TPTextField alloc] initWithFrame:CGRectMake(leftMargin, kPadding + 2*(textFieldHeight + kPadding), textFieldWidth, textFieldHeight)];
    self.age.keyboardType = UIKeyboardTypeNumberPad;
    [self.scrollView addSubview:self.age];
    
    TPLabel *educationLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + 3*(textFieldHeight + kPadding), labelWidth, textFieldHeight)];
    educationLabel.text = @"Education";
    [self.scrollView addSubview:educationLabel];
    self.education = [[TPTextField alloc] initWithFrame:CGRectMake(leftMargin, kPadding + 3*(textFieldHeight + kPadding), textFieldWidth, textFieldHeight)];
    [self.scrollView addSubview:self.education];

    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _femaleButton.frame.origin.y + _femaleButton.frame.size.height + kPadding);
    self.scrollView.scrollEnabled = YES;
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handButtonPressed:(UIButton *)sender {
    //this sucks, but I gotta ship today
    if (sender == _rightHandButton) {
        self.handedness = @"Right";
    } else if (sender == _leftHandButton) {
        self.handedness = @"Left";
    } else if (sender == _mixedHandButton) {
        self.handedness = @"Mixed";
    }
}
- (IBAction)genderButtonPressed:(UIButton *)sender {
    //this sucks, but I gotta ship today    
    if (sender == _maleButton) {
        self.gender = @"male";
    } else if (sender == _femaleButton) {
        self.gender = @"female";
    }
}

-(void)dismissKeyboard {
    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.age resignFirstResponder];
    [self.education resignFirstResponder];
}

-(void)loadData
{
    NSDictionary *user = _oauthClient.user;
    self.name.text = user[@"name"];
    self.email.text = user[@"email"];
    if (user[@"date_of_birth"] != [NSNull null]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm/dd/yyyy"];
        NSDate *dob = [dateFormatter dateFromString:user[@"date_of_birth"]];
        long long age = [[NSDate date] timeIntervalSinceDate:dob] / 3.15569e7;
    self.age.text = [NSString stringWithFormat:@"@",age];
    }


    self.education.text = user[@"education"];
    self.handedness = user[@"handedness"];
    self.gender = user[@"gender"];
}

-(void)setHandedness:(NSString *)handedness
{
    _handedness = handedness;
    
    _rightHandButton.selected = NO;
    _leftHandButton.selected = NO;
    _mixedHandButton.selected = NO;
    
    if ([_handedness isEqualToString:@"Right"]) {
        _rightHandButton.selected = YES;
    } else if ([_handedness isEqualToString:@"Left"]) {
        _leftHandButton.selected = YES;
    } else if ([_handedness isEqualToString:@"Mixed"]) {
        _mixedHandButton.selected = YES;
    }
}

-(void)setGender:(NSString *)gender
{
    _gender = gender;
    
    _maleButton.selected = NO;
    _femaleButton.selected = NO;

    if ([_gender isEqualToString:@"male"]) {
        _maleButton.selected = YES;
    } else if ([_gender isEqualToString:@"female"]) {
        _femaleButton.selected = YES;
    }
}

- (IBAction)saveButtonPressed:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.name.text forKey:@"name"];
    [params setValue:self.email.text forKey:@"email"];
    int age = [[[NSCalendar currentCalendar]
                components:NSYearCalendarUnit fromDate:[NSDate date]]
               year] - self.age.text.intValue;
    [params setValue:[NSString stringWithFormat:@"01/01/%i",age] forKey:@"age"];
    [params setValue:self.education.text forKey:@"education"];
    [params setValue:self.handedness forKey:@"handedness"];
    [params setValue:self.gender forKey:@"gender"];
    [params setValue:@1 forKey:@"is_dob_by_age"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scrollView animated:YES];
    hud.labelText = @"Saving...";
    [_oauthClient putPath:@"api/v1/users/-/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [_oauthClient handleError:error withOptionalMessage:@"There was an error saving data. Please try again."];
    }];
}
@end
