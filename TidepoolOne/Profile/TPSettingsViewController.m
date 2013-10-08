//
//  TPSettingsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSettingsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import "TPTextFieldCell.h"
#import "TPImageButtonsCell.h"

@interface TPSettingsViewController () <UIPickerViewDelegate, UIPickerViewDataSource, TPImageButtonsCellDelegate, TPTextFieldCellDelegate>
{
    TPOAuthClient *_oauthClient;
    BOOL _ageChanged;
    NSArray *_educationOptions;
    NSArray *_groups;
    NSArray *_fields;
    UIPickerView *_pickerView;
    NSMutableDictionary *_fieldValues;
}
@end

@implementation TPSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    _groups = @[@"Name and Email",@"Age",@"Education",@"Handedness",@"Gender"];
    [_oauthClient getUserInfoFromServerWithCompletionHandlersSuccess:^{
        _fields = @[@[@"Name", @"Email"],@[@"Age"],@[@"Education"],@[@"Handedness"],@[@"Gender"],];
        _fieldValues = [@{@"Name":@"",@"Email":@"",@"Age":@"",@"Education":@"",@"Handedness":@"",@"Gender":@"",} mutableCopy];
        [self loadData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _groups.count)] withRowAnimation:UITableViewRowAnimationBottom];
    } andFailure:^{
    }];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.delegate = self;


    [self.tableView registerClass:[TPTextFieldCell class] forCellReuseIdentifier:@"SettingsCell"];
    [self.tableView registerClass:[TPImageButtonsCell class] forCellReuseIdentifier:@"ButtonImageCell"];
    
    _ageChanged = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor colorWithWhite:245.0/255.0 alpha:1.0];
    
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
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Settings Screen"];
#endif
    
}

-(void)customizeFields:(NSArray *)fields
{
    for (TPTextField *field in fields) {
        field.textColor = [UIColor blackColor];
        field.layer.borderColor = [[UIColor blackColor] CGColor];
    }
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
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[TPTextFieldCell class]]) {
            TPTextFieldCell *textFieldCell = (TPTextFieldCell *)cell;
            [textFieldCell forceTextFieldReturn];
        }
    }
}

-(void)loadData
{
    NSDictionary *user = _oauthClient.user;
    if (user[@"name"] != [NSNull null]) {
        [_fieldValues setObject:user[@"name"] forKey:@"Name"];
    }
    [_fieldValues setObject:user[@"email"] forKey:@"Email"];
    if (user[@"date_of_birth"] != [NSNull null]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-mm-dd"];
        NSDate *dob = [dateFormatter dateFromString:user[@"date_of_birth"]];
        long long age = [[NSDate date] timeIntervalSinceDate:dob] / 3.15569e7;
        [_fieldValues setObject:[NSString stringWithFormat:@"%lld",age] forKey:@"Age"];
    }
    
    
    if (user[@"education"] != [NSNull null]) {
        [_fieldValues setObject:user[@"education"] forKey:@"Education"];
    }
    if (user[@"handedness"] != [NSNull null]) {
        [_fieldValues setObject:user[@"handedness"] forKey:@"Handedness"];
    }
    if (user[@"gender"] != [NSNull null]) {
        [_fieldValues setObject:user[@"gender"] forKey:@"Gender"];
    }
}

-(void)setHandedness:(NSString *)handedness
{
    [_fieldValues setValue:handedness forKey:@"Handedness"];
    _rightHandButton.selected = NO;
    _leftHandButton.selected = NO;
    _mixedHandButton.selected = NO;
    
    if ([handedness isEqualToString:@"right"]) {
        _rightHandButton.selected = YES;
    } else if ([handedness isEqualToString:@"left"]) {
        _leftHandButton.selected = YES;
    } else if ([handedness isEqualToString:@"mixed"]) {
        _mixedHandButton.selected = YES;
    }
}

-(void)setGender:(NSString *)gender
{
    [_fieldValues setValue:gender forKey:@"Gender"];
    _maleButton.selected = NO;
    _femaleButton.selected = NO;
    
    if ([gender isEqualToString:@"male"]) {
        _maleButton.selected = YES;
    } else if ([gender isEqualToString:@"female"]) {
        _femaleButton.selected = YES;
    }
}

-(void)changedAge
{
    _ageChanged = YES;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self dismissKeyboard];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:_fieldValues[@"Name"] forKey:@"name"];
    [params setValue:_fieldValues[@"Email"] forKey:@"email"];
    int age = [[[NSCalendar currentCalendar]
                components:NSYearCalendarUnit fromDate:[NSDate date]]
               year] - [_fieldValues[@"Age"] intValue];
    if (_ageChanged) {
        [params setValue:[NSString stringWithFormat:@"01/01/%i",age] forKey:@"date_of_birth"];
    }
    [params setValue:_fieldValues[@"Education"] forKey:@"education"];
    [params setValue:_fieldValues[@"Handedness"] forKey:@"handedness"];
    [params setValue:_fieldValues[@"Gender"] forKey:@"gender"];
    [params setValue:@1 forKey:@"is_dob_by_age"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";
    [_oauthClient putPath:@"api/v1/users/-/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Done";
        [hud hide:YES afterDelay:2.0];
        [_oauthClient getUserInfoFromServerWithCompletionHandlersSuccess:^{
        } andFailure:^{
        }];
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
    _fieldValues[@"Education"] = _educationOptions[row];
    [self.tableView reloadData];
//    for (UITableViewCell *cell in self.tableView.visibleCells) {
//        if ([cell isKindOfClass:[TPTextFieldCell class]]) {
//            TPTextFieldCell *textFieldCell = (TPTextFieldCell *)cell;
//            if ([textFieldCell.title isEqualToString:@"Education"]) {
//                textFieldCell.textField.text = _fieldValues[@"Education"];
//            }
//        }
//    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groups.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _groups[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_fields[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_groups[indexPath.section] isEqualToString:@"Gender"]) {
        TPImageButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonImageCell" forIndexPath:indexPath];
        cell.buttonImages = @[@[[UIImage imageNamed:@"male.png"],[UIImage imageNamed:@"male-pressed.png"]],
                              @[[UIImage imageNamed:@"female.png"],[UIImage imageNamed:@"female-pressed.png"]],];
        cell.values =@[@"male",@"female"];
        cell.currentValue = [_fieldValues objectForKey:@"Gender"];
        cell.title = _fields[indexPath.section][indexPath.row];
        cell.delegate = self;
        return cell;
    } else if ([_groups[indexPath.section] isEqualToString:@"Handedness"]) {
        TPImageButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonImageCell" forIndexPath:indexPath];
        cell.buttonImages = @[@[[UIImage imageNamed:@"righthand.png"],[UIImage imageNamed:@"righthand-pressed.png"]],
                              @[[UIImage imageNamed:@"lefthand.png"],[UIImage imageNamed:@"lefthand-pressed.png"]],
                              @[[UIImage imageNamed:@"mixedhand.png"],[UIImage imageNamed:@"mixedhand-pressed.png"]],];
        cell.values =@[@"right",@"left",@"mixed"];
        cell.currentValue = [_fieldValues objectForKey:@"Handedness"];
        cell.title = _fields[indexPath.section][indexPath.row];
        cell.delegate = self;
        return cell;
    } else {
        static NSString *CellIdentifier = @"SettingsCell";
        TPTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        cell.title = _fields[indexPath.section][indexPath.row];
        cell.textField.text = _fieldValues[cell.title];
        if ([cell.title isEqualToString:@"Age"]) {
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        } else if ([cell.title isEqualToString:@"Email"]) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        } else if ([cell.title isEqualToString:@"Education"]) {
            cell.textField.inputView = _pickerView;
        } else if ([cell.title isEqualToString:@"Email"]) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        } else if ([cell.title isEqualToString:@"Email"]) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        } else {
            cell.textField.keyboardType = UIKeyboardTypeDefault;
        }
        cell.delegate = self;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_groups[indexPath.section] isEqualToString:@"Gender"] || [_groups[indexPath.section] isEqualToString:@"Handedness"]) {
        return 150;
    }
    return 44;
}

#pragma mark TPImageButtonsCellDelegate methods

-(void)valueWasChosen:(NSString *)value inCell:(TPImageButtonsCell *)cell
{
    if (value) {
        [_fieldValues setObject:value forKey:cell.title];
    } else {
        [_fieldValues removeObjectForKey:cell.title];
    }
}

#pragma mark TPTextFieldCellDelegate methods

-(void)textFieldCell:(TPTextFieldCell *)cell wasUpdatedTo:(NSString *)string
{
    [_fieldValues setValue:string forKey:cell.title];
    if ([cell.title isEqualToString:@"Age"]) {
        [self changedAge];
    }
}

@end
