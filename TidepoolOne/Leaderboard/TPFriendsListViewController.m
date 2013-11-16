//
//  TPFriendsListViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/12/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFriendsListViewController.h"
#import "TPOAuthClient.h"
#import "TPFriendListCell.h"
#import "TPUserProfileViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface TPFriendsListViewController ()
{
    NSMutableArray *_friends;
    NSMutableArray *_deletedFriends;
}
@end

@implementation TPFriendsListViewController

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
    _deletedFriends = [@[] mutableCopy];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"TPFriendListCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [[TPOAuthClient sharedClient] getFriendListWithOffset:@0 Limit:@20 WithCompletionHandlersSuccess:^(NSArray *pendingList) {
        _friends = [pendingList mutableCopy];
        [self.tableView reloadData];
    } andFailure:^{
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:76/255. green:87/255. blue:105/255. alpha:1.0]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ff-btn-x-close.png"] style:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
    self.title = @"Friends";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissSelf
{
    if (_deletedFriends.count) {
        [[TPOAuthClient sharedClient] unfriendFriends:_deletedFriends withCompletionHandlersSuccess:^{
        } andFailure:^{
        }];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TPFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *friend = _friends[indexPath.row];
    cell.nameLabel.text = friend[@"name"];
    [cell.profilePictureView setImageWithURL:[NSURL URLWithString:friend[@"image"]]];
    cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.bounds.size.height  / 2;
    cell.profilePictureView.clipsToBounds = YES;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *friend = _friends[indexPath.row];
        [_friends removeObjectAtIndex:indexPath.row];
        [_deletedFriends addObject:friend];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *friend = _friends[indexPath.row];
    TPUserProfileViewController *vc = [[TPUserProfileViewController alloc] init];
    vc.userId = friend[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

@end
