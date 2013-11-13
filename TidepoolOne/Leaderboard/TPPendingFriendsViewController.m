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
    NSDictionary *friend = _friends[indexPath.row];
    cell.nameLabel.text = friend[@"email"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:friend[@"image"]]];
    cell.acceptButton.tag = cell.declineButton.tag = TAG_OFFSET + indexPath.row;
    [cell.acceptButton addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.declineButton addTarget:self action:@selector(rejectFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.acceptButton.selected = [_acceptedFriends containsObject:friend];
    cell.declineButton.selected = [_rejectedFriends containsObject:friend];
    if (cell.acceptButton.selected) {
        cell.declineButton.hidden = YES;
        cell.acceptButton.hidden = NO;
//        [UIView animateWithDuration:1.0 animations:^{
            cell.acceptButton.transform = CGAffineTransformMakeTranslation(75, 0);
//        }];
    } else {
//        [UIView animateWithDuration:1.0 animations:^{
            cell.acceptButton.transform = CGAffineTransformMakeTranslation(0, 0);
//        }];
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
    NSDictionary *friend = _friends[indexPath.row];
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
    NSDictionary *friend = _friends[indexPath.row];
    [_acceptedFriends removeObject:friend];
    if ([_rejectedFriends containsObject:friend]) {
        [_rejectedFriends removeObject:friend];
    } else {
        [_rejectedFriends addObject:friend];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
