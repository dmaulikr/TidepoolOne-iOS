//
//  TPSettingsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSettingsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

@interface TPSettingsViewController ()
{
    TPOAuthClient *_oauthClient;
    BOOL _ageChanged;
    NSArray *_educationOptions;
}
@end

@implementation TPSettingsViewController

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
    
    _ageChanged = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor colorWithWhite:245.0/255.0 alpha:1.0];
    float kPadding = 10;
    float leftMarginLabel = 10;
    float labelHeight = 25;
    float labelWidth = 150;
    float textFieldHeight = 44;
    float textFieldWidth = 270;
    float labelDistApart = textFieldHeight + 2*kPadding + labelHeight;
    TPLabel *nameLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding, labelWidth, textFieldHeight)];
    nameLabel.text = @"Name";
    self.name = [[TPTextField alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + labelHeight + kPadding, textFieldWidth, textFieldHeight)];
    self.name.textColor = [UIColor blackColor];

    TPLabel *emailLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + labelDistApart, labelWidth, textFieldHeight)];
    emailLabel.text = @"Email";
    self.email = [[TPTextField alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + labelHeight + kPadding + 1*labelDistApart, textFieldWidth, textFieldHeight)];
    self.email.textColor = [UIColor blackColor];
    
    TPLabel *ageLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + 2*(labelDistApart), labelWidth, textFieldHeight)];
    ageLabel.text = @"Age";
    self.age = [[TPTextField alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + labelHeight + kPadding + 2*labelDistApart, textFieldWidth, textFieldHeight)];
    self.age.keyboardType = UIKeyboardTypeNumberPad;
    self.age.textColor = [UIColor blackColor];
    
    [self.age addTarget:self action:@selector(changedAge) forControlEvents:UIControlEventEditingChanged];
    
    TPLabel *educationLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + 3*(labelDistApart), labelWidth, textFieldHeight)];
    educationLabel.text = @"Education";
    self.education = [[TPTextField alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + labelHeight + kPadding + 3*labelDistApart, textFieldWidth, textFieldHeight)];
    self.education.delegate = self;
    self.education.textColor = [UIColor blackColor];
    UIPickerView *pickerView = [UIPickerView new];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    self.education.inputView = pickerView;
    [self customizeFields:@[self.name,self.email,self.age,self.education]];

    
    TPLabel *handednessLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, kPadding + 4*(labelDistApart), labelWidth, textFieldHeight)];
    handednessLabel.text = @"Handedness";

    float handButtonsY = kPadding + 4*(labelDistApart) + 3*kPadding;
    UIImage *image;
    UIImage *imageSelected;
    image = [UIImage imageNamed:@"lefthand.png"];
    imageSelected = [UIImage imageNamed:@"lefthand-pressed.png"];
    self.leftHandButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.leftHandButton setImage:image forState:UIControlStateNormal];
    [self.leftHandButton setImage:imageSelected forState:UIControlStateSelected];
    self.leftHandButton.frame = CGRectMake(0, handButtonsY, image.size.width, image.size.height);
    self.leftHandButton.center = CGPointMake(self.view.bounds.size.width/5,self.leftHandButton.center.y);
    [self.leftHandButton addTarget:self action:@selector(handButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollContentView addSubview:self.leftHandButton];

    image = [UIImage imageNamed:@"righthand.png"];
    imageSelected = [UIImage imageNamed:@"righthand-pressed.png"];
    self.rightHandButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.rightHandButton setImage:image forState:UIControlStateNormal];
    [self.rightHandButton setImage:imageSelected forState:UIControlStateSelected];
    self.rightHandButton.frame = CGRectMake(0, handButtonsY, image.size.width, image.size.height);
    self.rightHandButton.center = CGPointMake(0.45*self.view.bounds.size.width,self.rightHandButton.center.y);
    [self.rightHandButton addTarget:self action:@selector(handButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollContentView addSubview:self.rightHandButton];

    image = [UIImage imageNamed:@"mixedhand.png"];
    imageSelected = [UIImage imageNamed:@"mixedhand-pressed.png"];
    self.mixedHandButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.mixedHandButton setImage:image forState:UIControlStateNormal];
    [self.mixedHandButton setImage:imageSelected forState:UIControlStateSelected];
    self.mixedHandButton.frame = CGRectMake(0, handButtonsY, image.size.width, image.size.height);
    self.mixedHandButton.center = CGPointMake(3*self.view.bounds.size.width/4,self.mixedHandButton.center.y);
    [self.mixedHandButton addTarget:self action:@selector(handButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollContentView addSubview:self.mixedHandButton];
    


    TPLabel *genderLabel = [[TPLabel alloc] initWithFrame:CGRectMake(leftMarginLabel, handButtonsY + self.leftHandButton.bounds.size.height + kPadding, labelWidth, textFieldHeight)];
    genderLabel.text = @"Gender";
    
    float genderButtonsY = handButtonsY + self.leftHandButton.bounds.size.height + kPadding + labelHeight + kPadding;
    image = [UIImage imageNamed:@"male.png"];
    imageSelected = [UIImage imageNamed:@"male-pressed.png"];
    self.maleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.maleButton setImage:image forState:UIControlStateNormal];
    [self.maleButton setImage:imageSelected forState:UIControlStateSelected];
    self.maleButton.frame = CGRectMake(0, genderButtonsY, image.size.width, image.size.height);
    self.maleButton.center = CGPointMake(self.view.bounds.size.width/3,self.maleButton.center.y);
    [self.maleButton addTarget:self action:@selector(genderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollContentView addSubview:self.maleButton];
    
    image = [UIImage imageNamed:@"female.png"];
    imageSelected = [UIImage imageNamed:@"female-pressed.png"];
    self.femaleButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.femaleButton setImage:image forState:UIControlStateNormal];
    [self.femaleButton setImage:imageSelected forState:UIControlStateSelected];
    self.femaleButton.frame = CGRectMake(0, genderButtonsY, image.size.width, image.size.height);
    self.femaleButton.center = CGPointMake(2*self.view.bounds.size.width/3,self.femaleButton.center.y);
    [self.femaleButton addTarget:self action:@selector(genderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollContentView addSubview:self.femaleButton];
    

    
    TPButton *logoutButton = [[TPButton alloc] initWithFrame:CGRectZero];
    logoutButton.frame = CGRectMake(120, genderButtonsY + self.maleButton.bounds.size.height + 3*kPadding, 130, 40);
    logoutButton.center = CGPointMake(self.view.bounds.size.width/2, logoutButton.center.y);
    [logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"btn-blue.png"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    
    [_scrollContentView addSubview:nameLabel];
    [_scrollContentView addSubview:self.name];
    [_scrollContentView addSubview:emailLabel];
    [_scrollContentView addSubview:self.email];
    [_scrollContentView addSubview:ageLabel];
    [_scrollContentView addSubview:self.age];
    [_scrollContentView addSubview:educationLabel];
    [_scrollContentView addSubview:self.education];
    [_scrollContentView addSubview:handednessLabel];
    [_scrollContentView addSubview:genderLabel];
    [_scrollContentView addSubview:logoutButton];
    
    
    
    _educationOptions = @[
                          @"High School - Freshman (9)",
                          @"High School - Sophomore (10)",
                          @"High School - Junior (11)",
                          @"High School - Senior (12)",
                          @"College - Less than 2 yrs",
                          @"College - Associates",
                          @"College - Bachelor's",
                          @"College - Master's",
                          @"College - Ph.D.",
                          @"Prefer not to answer",
                          ];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];

}

-(void)customizeFields:(NSArray *)fields
{
    for (TPTextField *field in fields) {
        field.textColor = [UIColor blackColor];
        field.layer.borderColor = [[UIColor blackColor] CGColor];
    }
}

-(void)viewDidLayoutSubviews
{
    _scrollContentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 800);
    [self.scrollView addSubview:_scrollContentView];
    [self.scrollView setContentSize:_scrollContentView.bounds.size];
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
        self.handedness = @"right";
    } else if (sender == _leftHandButton) {
        self.handedness = @"left";
    } else if (sender == _mixedHandButton) {
        self.handedness = @"mixed";
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

- (IBAction)logoutButtonPressed:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Log Out" message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [_oauthClient logout];
        [self.navigationController popViewControllerAnimated:YES];
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
    if (user[@"name"] != [NSNull null]) {
        self.name.text = user[@"name"];
    }
    self.email.text = user[@"email"];
    if (user[@"date_of_birth"] != [NSNull null]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-mm-dd"];
        NSDate *dob = [dateFormatter dateFromString:user[@"date_of_birth"]];
        long long age = [[NSDate date] timeIntervalSinceDate:dob] / 3.15569e7;
    self.age.text = [NSString stringWithFormat:@"%lld",age];
    }


    if (user[@"education"] != [NSNull null]) {
        self.education.text = user[@"education"];
    }
    if (user[@"handedness"] != [NSNull null]) {
        self.handedness = user[@"handedness"];
    }
    if (user[@"gender"] != [NSNull null]) {
        self.gender = user[@"gender"];
    }
}

-(void)setHandedness:(NSString *)handedness
{
    _handedness = handedness;
    
    _rightHandButton.selected = NO;
    _leftHandButton.selected = NO;
    _mixedHandButton.selected = NO;
    
    if ([_handedness isEqualToString:@"right"]) {
        _rightHandButton.selected = YES;
    } else if ([_handedness isEqualToString:@"left"]) {
        _leftHandButton.selected = YES;
    } else if ([_handedness isEqualToString:@"mixed"]) {
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

-(void)changedAge
{
    _ageChanged = YES;
}

- (IBAction)saveButtonPressed:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.name.text forKey:@"name"];
    [params setValue:self.email.text forKey:@"email"];
    int age = [[[NSCalendar currentCalendar]
                components:NSYearCalendarUnit fromDate:[NSDate date]]
               year] - self.age.text.intValue;
    if (_ageChanged) {
        [params setValue:[NSString stringWithFormat:@"01/01/%i",age] forKey:@"date_of_birth"];
    }
    [params setValue:self.education.text forKey:@"education"];
    [params setValue:self.handedness forKey:@"handedness"];
    [params setValue:self.gender forKey:@"gender"];
    [params setValue:@1 forKey:@"is_dob_by_age"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scrollView animated:YES];
    hud.labelText = @"Saving...";
    [_oauthClient putPath:@"api/v1/users/-/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Done";
        [hud hide:YES afterDelay:2.0];
        [_oauthClient getUserInfoFromServer];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [_oauthClient handleError:error withOptionalMessage:@"There was an error saving data. Please try again."];
    }];
}

#pragma mark PickerViewDelegate methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _educationOptions.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _educationOptions[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.education.text = _educationOptions[row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
