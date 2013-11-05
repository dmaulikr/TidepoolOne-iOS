//
//  TPLeaderboardViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/18/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLeaderboardViewController.h"
#import "TPLeaderBoardCell.h"

@interface TPLeaderboardViewController ()
{
    NSArray *_games;
    NSMutableDictionary *_gameHighScores;
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
    _games = @[@"faceoff", @"snoozer"];
    _gameHighScores = [@{@"faceoff":@[], @"snoozer":@[]} mutableCopy];
    
    [self refreshAllScores];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TPLeaderBoardCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 71)];
    UIImage *img = [UIImage imageNamed:@"leader-banner.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.center = self.tableView.tableHeaderView.center;
    [self.tableView.tableHeaderView addSubview:imgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshAllScores
{
    for (NSString *game in _games) {
        [[TPOAuthClient sharedClient] getLeaderboardsForGame:game WithCompletionHandlersSuccess:^(NSArray *leaders) {
            [_gameHighScores setObject:leaders forKey:game];
            [self.tableView reloadData];
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
    cell.usernameLabel.text = item[@"email"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"leader-header-%@.png", _games[section]]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 136)];
    imageView.image = image;
    return imageView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

@end
