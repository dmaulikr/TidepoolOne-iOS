//
//  TPLeaderboardViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/18/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLeaderboardViewController.h"
#import "TPLeaderBoardCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "TPUserProfileViewController.h"

@interface TPLeaderboardViewController ()
{
    NSArray *_games;
    NSMutableDictionary *_gameHighScores;
    __block int _refreshCount;
}
@end

@implementation TPLeaderboardViewController

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
    _games = @[@"faceoff", @"snoozer", @"echo"];
    _gameHighScores = [@{@"faceoff":@[], @"snoozer":@[], @"echo":@[]} mutableCopy];
    
    [self refreshAllScores];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TPLeaderBoardCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 71)];
    UIImage *img = [UIImage imageNamed:@"leader-banner.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.center = self.tableView.tableHeaderView.center;
    [self.tableView.tableHeaderView addSubview:imgView];
    
    self.refreshControl = [[UIRefreshControl alloc]
                           init];
    [self.refreshControl addTarget:self action:@selector(refreshAllScores) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = self.refreshControl;
    self.tableView.backgroundView.layer.zPosition -= 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshAllScores
{
    _refreshCount = 0;
    [self.refreshControl beginRefreshing];
    for (NSString *game in _games) {
        [[TPOAuthClient sharedClient] getLeaderboardsForGame:game WithCompletionHandlersSuccess:^(NSArray *leaders) {
            [_gameHighScores setObject:leaders forKey:game];
            [self.tableView reloadData];
            _refreshCount++;
            if (_refreshCount == _games.count) {
                [self.refreshControl endRefreshing];
            }
        } andFailure:^{
        }];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_games count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_gameHighScores[_games[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TPLeaderBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *item = _gameHighScores[_games[indexPath.section]][indexPath.row];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%@", item[@"score"]];
    NSString *pictureUrlString = item[@"image"];
    if (item[@"name"] && item[@"name"] != [NSNull null]) {
        cell.usernameLabel.text = item[@"name"];
    } else {
        cell.usernameLabel.text = [[item[@"email"] componentsSeparatedByString:@"@"] objectAtIndex:0];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (pictureUrlString && pictureUrlString != (NSString *)[NSNull null]) {
        [cell.userProfilePicture setImageWithURL:[NSURL URLWithString:pictureUrlString]];
    } else {
        cell.userProfilePicture.image = [UIImage imageNamed:@"leader-defaultuser.png"];
    }
    cell.userProfilePicture.layer.cornerRadius = cell.userProfilePicture.bounds.size.width / 2;
    cell.userProfilePicture.layer.masksToBounds = YES;
    [[TPOAuthClient sharedClient] getUserInfoLocallyIfPossibleWithCompletionHandlersSuccess:^(NSDictionary *user) {
        cell.isSelf = ([[item[@"id"] description] isEqualToString:[user[@"id"] description]]);
    } andFailure:^{
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_gameHighScores[_games[indexPath.section]] count] - 1) {
        return 92;
    }
    return 82;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"leader-header-%@.png", _games[section]]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    imageView.image = image;
    return imageView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = _gameHighScores[_games[indexPath.section]][indexPath.row];
    TPUserProfileViewController *vc = [[TPUserProfileViewController alloc] init];
    vc.userId = item[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
