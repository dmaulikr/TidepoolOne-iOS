//
//  TPProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPProfileViewController.h"
#import "TPSettingsViewController.h"
#import "TPProfileViewHeader.h"
#import "TPOAuthClient.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "TPPolarChartView.h"
#import "TPProfileTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPProfileViewController ()
{
    TPOAuthClient *_oauthClient;
    UIImageView *_imageView;
}
@end

@implementation TPProfileViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    [self setupView];
    [self loggedIn]; //by calling this here - we don't have to repopulate every time viewDidAppear - it is called when loaded and on every user change
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return !(!self.bulletPoints) + !(!self.paragraphs);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.bulletPoints.count;
        case 1:
            return self.paragraphs.count;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TPProfileTableViewCell" forIndexPath:indexPath];
    // Configure the cell...
    switch (indexPath.section) {
        case 0: {
            cell.rightTextLabel.attributedText = [self parsedFromMarkdown:self.bulletPoints[indexPath.row]];
            cell.centerTextLabel.hidden = YES;
            cell.ribbonImageView.hidden = NO;
            cell.rightTextLabel.hidden = NO;
            return cell;
        }
            break;
        case 1: {
            cell.centerTextLabel.attributedText = [self parsedFromMarkdown:self.paragraphs[indexPath.row]];
            cell.centerTextLabel.hidden = NO;
            cell.ribbonImageView.hidden = YES;
            cell.rightTextLabel.hidden = YES;
            return cell;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str;
    switch (indexPath.section) {
        case 0:{
            str = self.bulletPoints[indexPath.row];
            CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Karla-Regular" size:16] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 47, 999) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 40;
        }
            break;
        case 1:{
            str = self.paragraphs[indexPath.row];
            CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Karla-Regular" size:16] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 20, 999) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 40;
        }
            break;
        default:
            break;
    }
    return 0;
}

-(void)showSettings
{
    TPSettingsViewController *settingsVC = [[TPSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (_user) {
        NSDictionary *personality = _user[@"personality"];
        if (personality != [NSNull null]) {
            TPProfileViewHeader *profileHeaderView = self.tableView.tableHeaderView;
            _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",personality[@"profile_description"][@"display_id"]]];
            
            self.bulletPoints = personality[@"profile_description"][@"bullet_description"];
            NSMutableArray *paragraphs = [[personality[@"profile_description"][@"description"]  componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
            [paragraphs removeObject:@""];
            self.paragraphs = paragraphs;
            
            NSString *name = [_user valueForKey:@"name"];
            if (name != [NSNull null] && [name length] != 0 && name) {
                profileHeaderView.nameLabel.text = _user[@"name"];
            } else {
                profileHeaderView.nameLabel.text = _user[@"email"];
            }
            profileHeaderView.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",personality[@"profile_description"][@"display_id"]]];
            profileHeaderView.personalityTypeLabel.text = [personality[@"profile_description"][@"name"] uppercaseString];
            profileHeaderView.blurbLabel.attributedText = [self parsedFromMarkdown:personality[@"profile_description"][@"one_liner"]];
            TPPolarChartView *polarChartView = profileHeaderView.chartView;
            NSMutableArray *big5Values = [NSMutableArray array];
            NSArray *keys = @[@"openness",@"conscientiousness",@"extraversion",@"agreeableness",@"neuroticism",];
            for (NSString *key in keys) {
                [big5Values addObject:personality[@"big5_score"][key]];
            }
            polarChartView.data = big5Values;
        }
    }
    if (!user) {
        TPProfileViewHeader *profileHeaderView = self.tableView.tableHeaderView;
//        _imageView.image = nil;
        
        self.bulletPoints = nil;
        self.paragraphs = nil;
        profileHeaderView.nameLabel.text = nil;
//        profileHeaderView.badgeImageView.image = nil;
        profileHeaderView.personalityTypeLabel.text = nil;
        profileHeaderView.blurbLabel.attributedText = nil;
        TPPolarChartView *polarChartView = profileHeaderView.chartView;
        polarChartView.data = nil;
    }
    [self.tableView reloadData];
}

-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
//    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    NSDictionary *attributes = @{
                                 @(STRONG): @{NSFontAttributeName : strongFont,},
                                 @(EMPH): @{NSForegroundColorAttributeName : emColor,}
                                 };    
    // parse the markdown
    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
    
    return prettyText;
//    // assign it to a view object
//    myTextView.attributedText = prettyText;

}


-(void)loggedIn
{
    self.user = _oauthClient.user;
    if (!self.user) { //for cases when oauthclient is still loading user data
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading...";
        [_oauthClient getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            self.user = responseObject[@"data"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            [_oauthClient handleError:error withOptionalMessage:@"Unable to get user information"];
        }];
    }
}

-(void)setupView
{
    UINib *nib = [UINib nibWithNibName:@"TPProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TPProfileTableViewCell"];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _oauthClient = [TPOAuthClient sharedClient];
    self.title = @"Profile";
//    self.rightButton.target = self;
//    self.rightButton.action = @selector(showSettings);
    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = _imageView;
    
    
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPProfileViewHeader" owner:nil options:nil];
    NSLog([nibItems description]);
    TPProfileViewHeader *profileHeaderView;
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPProfileViewHeader class]]) {
            profileHeaderView = item;
        }
    }
    self.tableView.tableHeaderView = profileHeaderView;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backButtonItem;
}

-(void)loggedOut
{
    self.user = nil;
}

@end
