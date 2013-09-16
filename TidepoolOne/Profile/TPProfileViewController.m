//
//  TPProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPProfileViewController.h"
#import "TPProfileHeaderView.h"
#import "TPOAuthClient.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "TPPolarChartView.h"
#import "TPProfileTableViewCell.h"
#import "TPTabBarController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPProfileViewController ()
{
    TPOAuthClient *_oauthClient;
    UIImageView *_imageView;
    UIImageView *_startNewGameView;    
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
    [self constructStartNewGameView];
    [self loggedIn]; //by calling this here - we don't have to repopulate every time viewDidAppear - it is called when loaded and on every user change

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Profile Screen"];
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

-(void)setUser:(NSDictionary *)user
{
    BOOL hasData = NO;
    NSDictionary *personality;
    _user = user;
    if (_user) {
        personality = _user[@"personality"];
        if (personality && (personality != (NSDictionary *)[NSNull null])) {
            hasData = YES;
        }
    }
    if (hasData) {
        [_startNewGameView removeFromSuperview];
        
        TPProfileHeaderView *profileHeaderView = (TPProfileHeaderView *)self.tableView.tableHeaderView;
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",personality[@"profile_description"][@"display_id"]]];
        
        self.bulletPoints = personality[@"profile_description"][@"bullet_description"];
        NSMutableArray *paragraphs = [[personality[@"profile_description"][@"description"]  componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
        [paragraphs removeObject:@""];
        self.paragraphs = paragraphs;
        
        NSString *name = [_user valueForKey:@"name"];
        if (name != (NSString *)[NSNull null] && [name length] != 0 && name) {
            profileHeaderView.nameLabel.text = _user[@"name"];
        } else {
            profileHeaderView.nameLabel.text = _user[@"email"];
        }
        profileHeaderView.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",personality[@"profile_description"][@"display_id"]]];
        profileHeaderView.personalityTypeLabel.text = [personality[@"profile_description"][@"name"] uppercaseString];
        profileHeaderView.blurbLabel.attributedText = [self parsedFromMarkdown:personality[@"profile_description"][@"one_liner"]];
        TPPolarChartView *polarChartView = (TPPolarChartView *)profileHeaderView.chartView;
        NSMutableArray *big5Values = [NSMutableArray array];
        NSArray *keys = @[@"openness",@"conscientiousness",@"extraversion",@"agreeableness",@"neuroticism",];
        for (NSString *key in keys) {
            [big5Values addObject:personality[@"big5_score"][key]];
        }
        polarChartView.data = big5Values;
    } else {
        _startNewGameView.hidden = NO;
        
        TPProfileHeaderView *profileHeaderView = (TPProfileHeaderView *)self.tableView.tableHeaderView;
        //        _imageView.image = nil;
        
        self.bulletPoints = nil;
        self.paragraphs = nil;
        profileHeaderView.nameLabel.text = nil;
        //        profileHeaderView.badgeImageView.image = nil;
        profileHeaderView.personalityTypeLabel.text = nil;
        profileHeaderView.blurbLabel.attributedText = nil;
        TPPolarChartView *polarChartView = (TPPolarChartView *)profileHeaderView.chartView;
        polarChartView.data = nil;
    }
    [self.tableView reloadData];
}

-(void)constructStartNewGameView
{
    _startNewGameView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _startNewGameView.image = [UIImage imageNamed:@"personality-placeholderbg.jpg"];
    _startNewGameView.contentMode = UIViewContentModeScaleAspectFill;
    _startNewGameView.userInteractionEnabled = YES;
    UIButton *startPersonalityGameButton = [[TPButton alloc] initWithFrame:CGRectZero];
//    [startPersonalityGameButton.titleLabel setFont:[UIFont fontWithName:startPersonalityGameButton.titleLabel.font.fontName size:startPersonalityGameButton.titleLabel.font.pointSize + 10]];
    UIImage *buttonImage = [UIImage imageNamed:@"btn-red.png"];
    startPersonalityGameButton.bounds = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    startPersonalityGameButton.center = self.view.center;
    [startPersonalityGameButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [startPersonalityGameButton addTarget:(TPTabBarController *)self.tabBarController action:@selector(showPersonalityGame) forControlEvents:UIControlEventTouchUpInside];
    [startPersonalityGameButton setTitle:@"Play Game" forState:UIControlStateNormal];
    startPersonalityGameButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    startPersonalityGameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_startNewGameView addSubview:startPersonalityGameButton];
    [self.view addSubview:_startNewGameView];
    
    float padding = 10;
    UILabel *textLabel = [[TPLabel alloc] initWithFrame:CGRectMake(padding, 0, self.view.bounds.size.width - 2*padding, 150)];
    textLabel.text = @"Discover your unique personality from 60 unique personality types.";
    [_startNewGameView addSubview:textLabel];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    startPersonalityGameButton.center = CGPointMake(startPersonalityGameButton.center.x, textLabel.center.y + textLabel.bounds.size.height/2 + 100);
}
-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
    //    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor blackColor];
    //    [UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0];
    
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
    NSLog(@"logged in called in profileVC");
    if (!self.user) { //for cases when oauthclient is still loading user data
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading...";
        [_oauthClient getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            self.user = responseObject[@"data"];
            _oauthClient.user = self.user;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            [_oauthClient handleError:error withOptionalMessage:@"Unable to get user information"];
        }];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"Highlights",@"Details"][section];
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
    
    
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPProfileHeaderView" owner:nil options:nil];
    TPProfileHeaderView *profileHeaderView;
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPProfileHeaderView class]]) {
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
