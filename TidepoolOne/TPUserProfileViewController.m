//
//  TPUserProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPUserProfileViewController.h"
#import "TPUserProfileCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPUserProfileViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_gameAggregateResults;
}
@end

@implementation TPUserProfileViewController

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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TPUserProfileCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self applyUserToView];
    _profilePictureView.layer.cornerRadius = _profilePictureView.bounds.size.width / 2;
    _profilePictureView.clipsToBounds = YES;
    [self refreshUser];
    
    self.acceptFriendButton.hidden = self.rejectFriendButton.hidden = self.blurbView.hidden = self.friendsButton.hidden = self.addToFriendButton.hidden = self.pendingFriendLabel.hidden = YES;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                UITextAttributeTextColor,
                                [UIColor clearColor],
                                UITextAttributeTextShadowColor, nil];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applyUserToView
{
    if (!_user) return;
    NSDictionary *personality = _user.personality;
    if (personality && [personality allKeys].count > 1) { // hack - why is personality returning a dictionary at all?
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",personality[@"profile_description"][@"display_id"]]];
        _personalityBadgeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",personality[@"profile_description"][@"display_id"]]];
        _blurbView.attributedText = [self parsedFromMarkdown:personality[@"profile_description"][@"one_liner"]];
        _personalityLabelView.text = [personality[@"profile_description"][@"name"] uppercaseString];        
    }
    [_profilePictureView setImageWithURL:[NSURL URLWithString:_user.image]];
    
    if (_user.name) {
        _usernameView.text = _user.name;
    } else {
        _usernameView.text = [[_user.email componentsSeparatedByString:@"@"] objectAtIndex:0];
    }

    
    NSArray *invalidTypes = @[@"SleepAggregateResult", @"ActivityAggregateResult"];
    NSMutableArray *validAggregateResults = [@[] mutableCopy];
    
    for (NSDictionary *result in _user.aggregateResults) {
        if (![invalidTypes containsObject:result[@"type"]]) {
            [validAggregateResults addObject:result];
        }
    }
    _gameAggregateResults = validAggregateResults;

    self.acceptFriendButton.hidden = self.rejectFriendButton.hidden = self.blurbView.hidden = self.friendsButton.hidden = self.addToFriendButton.hidden = self.pendingFriendLabel.hidden = YES;
    
    [[TPOAuthClient sharedClient] getUserInfoLocallyIfPossibleWithCompletionHandlersSuccess:^(TPUser *user) {
        if ([[user.id description] isEqualToString:[self.user.id description]]) {
            self.addToFriendButton.hidden = self.friendsButton.hidden = YES;
            self.blurbView.hidden = NO;
        }
    } andFailure:^{
    }];
    
    
    if ([_user.friendStatus isEqualToString:@"friend"]) {
        self.blurbView.hidden = self.friendsButton.hidden = NO;
    } else if ([_user.friendStatus isEqualToString:@"not_friend"]) {
        self.addToFriendButton.hidden = NO;
        self.personalityBadgeView.image = [UIImage imageNamed:@"badge-private.png"];
    } else if ([_user.friendStatus isEqualToString:@"pending"]) {
        self.addToFriendButton.hidden = NO;
        self.addToFriendButton.selected = YES;
    } else if ([_user.friendStatus isEqualToString:@"invited_by"]) {
        self.acceptFriendButton.hidden = self.rejectFriendButton.hidden = self.pendingFriendLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_gameAggregateResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TPUserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *item = _gameAggregateResults[indexPath.section];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%@", item[@"high_scores"][@"all_time_best"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *pictureChoice = @{
                                   @"EmoAggregateResult": @"faceoff",
                                   @"SpeedAggregateResult": @"snoozer",
                                   @"AttentionAggregateResult": @"echo",
                                   };
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"pubprofile-%@.png", pictureChoice[_gameAggregateResults[indexPath.section][@"type"]]]];
    cell.gameImageView.image = image;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (IBAction)addToFriendsButtonPressed:(UIButton *)sender
{
    [[TPOAuthClient sharedClient] inviteFriends:@[self.user] WithCompletionHandlersSuccess:^{
        self.addToFriendButton.selected = YES;
    } andFailure:^{
    }];
}

- (IBAction)acceptFriendPressed:(id)sender {
    [[TPOAuthClient sharedClient] acceptPendingFriends:@[self.user] WithCompletionHandlersSuccess:^{
        [self refreshUser];
    } andFailure:^{
    }];
}

- (IBAction)rejectFriendPressed:(id)sender {
    [[TPOAuthClient sharedClient] rejectPendingFriends:@[self.user] WithCompletionHandlersSuccess:^{
        [self refreshUser];
    } andFailure:^{
    }];
}

-(void)refreshUser
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    [[TPOAuthClient sharedClient] getUserInfoWithId:self.userId withCompletionHandlersSuccess:^(TPUser *user) {
        self.user = user;
        [self applyUserToView];
        [hud hide:YES];
    } andFailure:^{
        [hud hide:YES];
    }];
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

@end
