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
#import "TPSettingsHeaderView.h"
#import "TPConnectionsCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "TPServiceLoginViewController.h"
#import "TPWebViewController.h"


@interface TPSettingsViewController () <UIPickerViewDelegate, UIPickerViewDataSource, TPImageButtonsCellDelegate, TPTextFieldCellDelegate, TPConnectionsCellDelegate>
{
    TPOAuthClient *_oauthClient;
    BOOL _ageChanged;
    NSArray *_educationOptions;
    NSArray *_groups;
    UIPickerView *_pickerView;
    NSMutableDictionary *_fieldValues;
    TPSettingsHeaderView *_headerView;
    NSMutableArray *_connections;
    UITapGestureRecognizer *_tap;
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
    _groups = @[@"name",@"email",@"age",@"education",@"connections",@"handedness",@"gender",@"about"];
    
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPSettingsHeaderView" owner:nil options:nil];
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPSettingsHeaderView class]]) {
            _headerView = item;
        }
    }
    self.tableView.tableHeaderView = _headerView;
    [_oauthClient getUserInfoLocallyIfPossibleWithCompletionHandlersSuccess:^(TPUser *user) {
        _fieldValues = [@{@"name":@"",@"email":@"",@"age":@"",@"education":@"",@"connections":@[@"fitbit"],@"handedness":@"",@"gender":@"",@"about":@[@"Terms & Conditions",@"Privacy Policy",@"Attribution"]} mutableCopy];
        _connections = [@[] mutableCopy];
        [self loadData];
    } andFailure:^{
    }];
    
    [_headerView.profilePictureButton addTarget:self action:@selector(changeProfilePicture) forControlEvents:UIControlEventTouchUpInside];
    [_headerView.logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.delegate = self;


    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DisclosureCell"];
    [self.tableView registerClass:[TPTextFieldCell class] forCellReuseIdentifier:@"SettingsCell"];
    [self.tableView registerClass:[TPImageButtonsCell class] forCellReuseIdentifier:@"ButtonImageCell"];
    [self.tableView registerClass:[TPConnectionsCell class] forCellReuseIdentifier:@"ConnectionsCell"];
    
    _ageChanged = NO;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_tap];
    _tap.cancelsTouchesInView = NO;
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
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 10, 100, 30)];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"btn-red.png"] forState:UIControlStateNormal];
    [logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutButton];
    self.tableView.tableFooterView = footerView;
    
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
    TPUser *user = _oauthClient.user;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-dd"];
    NSDate *dob = [dateFormatter dateFromString:user.dateOfBirth];
    long long age = [[NSDate date] timeIntervalSinceDate:dob] / 3.15569e7;
    [_fieldValues setObject:[NSString stringWithFormat:@"%lld",age] forKey:@"age"];
    
    NSArray *keys = @[@"name",@"email",@"education",@"handedness",@"gender",];
    for (NSString *key in keys) {
        if (user.userDictionary[key] != [NSNull null]) {
            [_fieldValues setObject:user.userDictionary[key] forKey:key];
        }
    }
    if (user.image) {
        [_headerView.profilePicture setImageWithURL:[NSURL URLWithString:user.image]];
    } else {
        _headerView.profilePicture.image = [UIImage imageNamed:@"default-profile-pic.png"];
    }
    NSArray *authentications = user.authentications;
    for (NSDictionary *authentication in authentications) {
        [_connections addObject:authentication[@"provider"]];
    }
}

-(void)changedAge
{
    _ageChanged = YES;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self dismissKeyboard];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"name",@"email",@"education",@"handedness",@"gender",];
    for (NSString *key in keys) {
        [params setValue:_fieldValues[key] forKey:key];
    }
    int age = [[[NSCalendar currentCalendar]
                components:NSYearCalendarUnit fromDate:[NSDate date]]
               year] - [_fieldValues[@"age"] intValue];
    if (_ageChanged) {
        [params setValue:[NSString stringWithFormat:@"01/01/%i",age] forKey:@"date_of_birth"];
    }
    [params setValue:@1 forKey:@"is_dob_by_age"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";
    [_oauthClient updateUserWithParameters:params withCompletionHandlersSuccess:^(TPUser *user) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Done";
        [hud hide:YES afterDelay:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } andFailure:^{
        [hud hide:YES];
    }];
}

-(void)changeProfilePicture
{
    
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
    _fieldValues[@"education"] = _educationOptions[row];
    [self.tableView reloadData];
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
    if ([_fieldValues[_groups[section]] isKindOfClass:[NSArray class]]) {
        return [_fieldValues[_groups[section]] count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_groups[indexPath.section] isEqualToString:@"gender"]) {
        TPImageButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonImageCell" forIndexPath:indexPath];
        cell.buttonImages = @[@[[UIImage imageNamed:@"male.png"],[UIImage imageNamed:@"male-pressed.png"]],
                              @[[UIImage imageNamed:@"female.png"],[UIImage imageNamed:@"female-pressed.png"]],];
        cell.values =@[@"male",@"female"];
        cell.currentValue = [_fieldValues objectForKey:@"gender"];
        cell.title = _groups[indexPath.section];
        cell.delegate = self;
        return cell;
    } else if ([_groups[indexPath.section] isEqualToString:@"handedness"]) {
        TPImageButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonImageCell" forIndexPath:indexPath];
        cell.buttonImages = @[@[[UIImage imageNamed:@"righthand.png"],[UIImage imageNamed:@"righthand-pressed.png"]],
                              @[[UIImage imageNamed:@"lefthand.png"],[UIImage imageNamed:@"lefthand-pressed.png"]],
                              @[[UIImage imageNamed:@"mixedhand.png"],[UIImage imageNamed:@"mixedhand-pressed.png"]],];
        cell.values =@[@"right",@"left",@"mixed"];
        cell.currentValue = [_fieldValues objectForKey:@"handedness"];
        cell.title = _groups[indexPath.section];
        cell.delegate = self;
        return cell;
    } else if ([_groups[indexPath.section] isEqualToString:@"connections"]) {
        TPConnectionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionsCell" forIndexPath:indexPath];
        cell.provider = _fieldValues[_groups[indexPath.section]][indexPath.row];
        if ([_connections containsObject:cell.provider]) {
            cell.switchIndicator.on = YES;
        }
        cell.delegate = self;
        return cell;
    } else if ([_groups[indexPath.section] isEqualToString:@"about"]){
        static NSString *CellIdentifier = @"DisclosureCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = _fieldValues[_groups[indexPath.section]][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        static NSString *CellIdentifier = @"SettingsCell";
        TPTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        cell.title = _groups[indexPath.section];
        cell.textField.text = _fieldValues[cell.title];
        if ([cell.title isEqualToString:@"age"]) {
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        } else if ([cell.title isEqualToString:@"email"]) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress
            ;
        } else if ([cell.title isEqualToString:@"education"]) {
            cell.textField.inputView = _pickerView;
        } else {
            cell.textField.keyboardType = UIKeyboardTypeDefault;
        }
        cell.delegate = self;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_groups[indexPath.section] isEqualToString:@"gender"] || [_groups[indexPath.section] isEqualToString:@"handedness"]) {
        return 150;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_groups[indexPath.section] isEqualToString:@"about"]){
        NSArray *fields = _fieldValues[_groups[indexPath.section]];
        NSString *field = fields[indexPath.row];
        if ([field isEqualToString:@"Privacy Policy"]) {
            TPWebViewController *webViewVC = [[TPWebViewController alloc] init];
            webViewVC.request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:@"http://www.tidepool.co/privacy.html"]];
            [self.navigationController pushViewController:webViewVC animated:YES];
        } else if ([field isEqualToString:@"Terms & Conditions"]) {
            TPWebViewController *webViewVC = [[TPWebViewController alloc] init];
            webViewVC.request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:@"http://www.tidepool.co/toc.html"]];
            [self.navigationController pushViewController:webViewVC animated:YES];
        } else if ([field isEqualToString:@"Attribution"]) {
            TPWebViewController *webViewVC = [[TPWebViewController alloc] init];
            webViewVC.request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:@"http://www.tidepool.co/attribution.html"]];
            [self.navigationController pushViewController:webViewVC animated:YES];
        }
    }

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
    if ([cell.title isEqualToString:@"age"]) {
        [self changedAge];
    }
}

#pragma mark TPConnectionCellDelegate methods
-(void)connectionsCell:(TPConnectionsCell *)cell tryingToSetConnectionStateTo:(BOOL)connected
{
    if (connected) {
        TPServiceLoginViewController *serviceVC = [[TPServiceLoginViewController alloc] init];
        [serviceVC setCompletionHandlersSuccess:^{
            cell.switchIndicator.on = YES;
            [_oauthClient forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:^(TPUser *user) {} andFailure:^{}];
        } andFailure:^{
            cell.switchIndicator.on = NO;
        }];
        serviceVC.view.frame = self.view.bounds;
        [self.navigationController pushViewController:serviceVC animated:YES];
    } else {
        [_oauthClient deleteConnectionForProvider:cell.provider];
    }
}

@end
