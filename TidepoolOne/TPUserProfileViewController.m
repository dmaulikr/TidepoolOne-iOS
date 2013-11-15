//
//  TPUserProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPUserProfileViewController.h"
#import "TPLeaderBoardCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

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
    [self.tableView registerNib:[UINib nibWithNibName:@"TPLeaderBoardCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self applyUserToView];
    _profilePictureView.layer.cornerRadius = _profilePictureView.bounds.size.width / 2;
    _profilePictureView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)applyUserToView
{
    if (!_user) return;
    _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",_user[@"personality"][@"profile_description"][@"display_id"]]];
    [_profilePictureView setImageWithURL:[NSURL URLWithString:_user[@"image"]]];
    _usernameView.text = _user[@"name"];
    _personalityBadgeView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",_user[@"personality"][@"profile_description"][@"display_id"]]];
    _blurbView.text = _user[@"personality"][@"profile_description"][@"one_liner"];
    _personalityLabelView.text = [_user[@"personality"][@"profile_description"][@"name"] uppercaseString];
    
    NSArray *invalidTypes = @[@"SleepAggregateResult", @"ActivityAggregateResult"];
    NSMutableArray *validAggregateResults = [@[] mutableCopy];
    
    for (NSDictionary *result in _user[@"aggregate_results"]) {
        if (![invalidTypes containsObject:result[@"type"]]) {
            [validAggregateResults addObject:result];
        }
    }
    _gameAggregateResults = validAggregateResults;
    
    if ([_user[@"friend_status"] isEqualToString:@"friend"]) {
        self.addToFriendButton.hidden = YES;
    } else if ([_user[@"friend_status"] isEqualToString:@"not_friend"]) {
        self.friendsButton.hidden = self.blurbView.hidden = YES;
    } else if ([_user[@"friend_status"] isEqualToString:@"pending"]) {
        self.friendsButton.hidden = self.blurbView.hidden = YES;
        self.addToFriendButton.selected = YES;
    } else if ([_user[@"friend_status"] isEqualToString:@"invited_by"]) {
        self.friendsButton.hidden = self.blurbView.hidden = YES;
    }
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
    TPLeaderBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *item = _gameAggregateResults[indexPath.section];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%@", item[@"high_scores"][@"all_time_best"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *headerChoice = @{
                                   @"EmoAggregateResult": @"echo",
                                   @"SpeedAggregateResult": @"snoozer",
                                   @"AttentionAggregateResult": @"echo",
                                   };
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"leader-header-%@.png", headerChoice[_gameAggregateResults[section][@"type"]]]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    imageView.image = image;
    return imageView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}


- (IBAction)addToFriendsButtonPressed:(UIButton *)sender
{
    [self.addToFriendButton setImage:[UIImage imageNamed:@"pubprofile-pendfriend.png"] forState:UIControlStateNormal];
    //Todo: implement
    [[TPOAuthClient sharedClient] inviteFriends:@[] WithCompletionHandlersSuccess:^{
    } andFailure:^{
    }];
}


@end
