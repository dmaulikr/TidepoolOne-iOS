//
//  TPPendingFriendsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/12/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPendingFriendsViewController.h"
#import "TPPendingFriendListCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "TPUserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TAG_OFFSET 666

@interface TPPendingFriendsViewController ()
{
    NSMutableArray *_friends;
    NSMutableArray *_acceptedFriends;
    NSMutableArray *_rejectedFriends;
}
@end

@implementation TPPendingFriendsViewController

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
    _acceptedFriends = [@[] mutableCopy];
    _rejectedFriends = [@[] mutableCopy];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"TPPendingFriendListCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[TPOAuthClient sharedClient] getPendingFriendListWithOffset:@0 Limit:@20 WithCompletionHandlersSuccess:^(NSArray *pendingList) {
        _friends = [pendingList mutableCopy];
        [self.tableView reloadData];
    } andFailure:^{
        
    }];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:76/255. green:87/255. blue:105/255. alpha:1.0]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ff-btn-x-close.png"] style:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
    self.title = @"Pending Friends";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissSelf
{
    if (_acceptedFriends.count) {
        [[TPOAuthClient sharedClient] acceptPendingFriends:_acceptedFriends WithCompletionHandlersSuccess:^{
        } andFailure:^{
        }];
    }
    if (_rejectedFriends.count) {
        [[TPOAuthClient sharedClient] rejectPendingFriends:_rejectedFriends WithCompletionHandlersSuccess:^{
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
    TPPendingFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    TPUser *friend = _friends[indexPath.row];
    cell.nameLabel.text = friend.email;
    [cell.profilePictureView setImageWithURL:[NSURL URLWithString:friend.image]];
    cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.bounds.size.height / 2;
    cell.profilePictureView.clipsToBounds = YES;
    cell.acceptButton.tag = cell.declineButton.tag = TAG_OFFSET + indexPath.row;
    [cell.acceptButton addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.declineButton addTarget:self action:@selector(rejectFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.acceptButton.selected = [_acceptedFriends containsObject:friend];
    cell.declineButton.selected = [_rejectedFriends containsObject:friend];
    if (cell.acceptButton.selected) {
        cell.declineButton.hidden = YES;
        cell.acceptButton.hidden = NO;
            cell.acceptButton.transform = CGAffineTransformMakeTranslation(92, 0);
    } else {
            cell.acceptButton.transform = CGAffineTransformMakeTranslation(0, 0);
    }
    if (cell.declineButton.selected) {
        cell.acceptButton.hidden = YES;
        cell.declineButton.hidden = NO;
    }
    return cell;
}

-(void)acceptFriend:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag - TAG_OFFSET inSection:0];
    TPUser *friend = _friends[indexPath.row];
    [_rejectedFriends removeObject:friend];
    if ([_acceptedFriends containsObject:friend]) {
        [_acceptedFriends removeObject:friend];
    } else {
        [_acceptedFriends addObject:friend];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


-(void)rejectFriend:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag - TAG_OFFSET inSection:0];
    TPUser *friend = _friends[indexPath.row];
    [_acceptedFriends removeObject:friend];
    if ([_rejectedFriends containsObject:friend]) {
        [_rejectedFriends removeObject:friend];
    } else {
        [_rejectedFriends addObject:friend];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPUser *friend = _friends[indexPath.row];
    TPUserProfileViewController *vc = [[TPUserProfileViewController alloc] init];
    vc.userId = friend.id;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

@end
