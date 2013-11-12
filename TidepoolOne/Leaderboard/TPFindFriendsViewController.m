//
//  TPFindFriendsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/4/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFindFriendsViewController.h"
#import <RHAddressBook/RHAddressBook.h>
#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>
#import <RHPerson.h>

#define PAGING 20

@interface TPFindFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    RHAddressBook *_ab;
    NSMutableArray *_foundFriends;
}
@end

@implementation TPFindFriendsViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.sourceSelector addTarget:self action:@selector(sourceChanged:) forControlEvents:UIControlEventValueChanged];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [[TPOAuthClient sharedClient] getPendingFriendListWithOffset:@0 Limit:@20 WithCompletionHandlersSuccess:^(NSArray *pendingList) {
        NSLog([pendingList description]);
    } andFailure:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sourceChanged:(UISegmentedControl *)sender
{
    if (!sender.selectedSegmentIndex) {
        //contacts
        [self findContacts];
    } else {
        //facebook
        [self findFacebookFriends];
    }
}



-(void)findFacebookFriends
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSMutableArray *facebookIds = [@[] mutableCopy];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [facebookIds addObject:friend.id];
        }
        [self startPagingFacebookList:facebookIds startingAtIndex:0];
    }];
}


-(void)findContacts
{
    _ab = [[RHAddressBook alloc] init];
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined){
        //request authorization
        [_ab requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            NSArray *emailList = [self getAllContacts];
            [self startPagingEmailList:emailList startingAtIndex:0];
        }];
    } else {
        NSArray *emailList = [self getAllContacts];
        [self startPagingEmailList:emailList startingAtIndex:0];
    }
}

-(NSArray *)getAllContacts
{
    NSArray *contacts = [_ab peopleOrderedByUsersPreference];
    NSMutableArray *emailList = [@[] mutableCopy];
    for (RHPerson *contact in contacts) {
        NSArray *emails = contact.emails.values;
        for (NSString *email in emails) {
            [emailList addObject:email];
        }
    }
    return emailList;
}


-(void)startPagingEmailList:(NSArray *)emailList startingAtIndex:(int)index
{
    NSLog(@"doing %i", index);
    if (index > emailList.count) {
        return;
    } else if (!index) {
        _foundFriends = [@[] mutableCopy];
    }
    int numItems = MIN(index + PAGING, emailList.count) - index;
    NSArray *subList = [emailList subarrayWithRange:NSMakeRange(index, numItems)];
    [[TPOAuthClient sharedClient] findFriendsWithEmail:subList WithCompletionHandlersSuccess:^(NSArray *newUsers) {
        [self startPagingEmailList:emailList startingAtIndex:index + PAGING];
        [_foundFriends addObjectsFromArray:newUsers];
        [self.tableView reloadData];
    } andFailure:^{
    }];
}

-(void)startPagingFacebookList:(NSArray *)fbList startingAtIndex:(int)index
{
    if (index > fbList.count) {
        return;
    } else if (!index) {
        _foundFriends = [@[] mutableCopy];
    }
    int numItems = MIN(index + PAGING, fbList.count) - index;
    NSArray *subList = [fbList subarrayWithRange:NSMakeRange(index, numItems)];
    [[TPOAuthClient sharedClient] findFriendsWithFacebookIds:subList WithCompletionHandlersSuccess:^(NSArray *newUsers) {
        [self startPagingFacebookList:fbList startingAtIndex:index + PAGING];
        [_foundFriends addObjectsFromArray:newUsers];
        [self.tableView reloadData];
    } andFailure:^{
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_foundFriends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = _foundFriends[indexPath.row][@"email"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *friend = _foundFriends[indexPath.row];
    [[TPOAuthClient sharedClient] inviteFriends:@[friend] WithCompletionHandlersSuccess:^{
        NSLog(@"added");
    } andFailure:^{
    }];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
