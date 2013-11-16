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
#import "TPFindFriendsCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "TPUserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TPAppDelegate.h"

#define PAGING 20
#define TAG_OFFSET 666

@interface TPFindFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    RHAddressBook *_ab;
    NSMutableArray *_foundEmailFriends;
    NSMutableArray *_foundFacebookFriends;
    NSMutableArray *_selectedEmailFriends;
    NSMutableArray *_selectedFacebookFriends;
    
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
    _selectedEmailFriends = [@[] mutableCopy];
    _selectedFacebookFriends = [@[] mutableCopy];
    // Do any additional setup after loading the view from its nib.
    [self.sourceSelector addTarget:self action:@selector(sourceChanged:) forControlEvents:UIControlEventValueChanged];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"TPFindFriendsCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:76/255. green:87/255. blue:105/255. alpha:1.0]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ff-btn-x-close.png"] style:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add all" style:UIBarButtonSystemItemCancel target:self action:@selector(addAllFriends)];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                UITextAttributeTextColor,
                                [UIColor clearColor],
                                UITextAttributeTextShadowColor, nil];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];

    self.title = @"Find Friends";
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
        self.findFriendsMode = TPFindFriendsViewModeContacts;
    } else {
        //facebook
        self.findFriendsMode = TPFindFriendsViewModeFacebook;
    }
}

-(void)setFindFriendsMode:(TPFindFriendsViewMode)findFriendsMode
{
    _findFriendsMode = findFriendsMode;
    switch (findFriendsMode) {
        case TPFindFriendsViewModeContacts:
        {
            [self findContacts];
        }
            break;
        case TPFindFriendsViewModeFacebook:
        {
            [self findFacebookFriends];
        }
            break;
            
        default:
            break;
    }
}


-(void)findFacebookFriends
{
    if (_foundFacebookFriends) {
        return;
    }
    TPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate openSessionWithAllowLoginUI:YES completionHandlersSuccess:^{
        _foundFacebookFriends = [@[] mutableCopy];
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSArray* friends = [result objectForKey:@"data"];
            NSMutableArray *facebookIds = [@[] mutableCopy];
            NSLog(@"Found: %i friends", friends.count);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                [facebookIds addObject:friend.id];
            }
            [self startPagingFacebookList:facebookIds startingAtIndex:0];
        }];
    } andFailure:^{
        [[[UIAlertView alloc] initWithTitle:@"Facebook login failed" message:@"Facebook login failed for a unknown reason. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
}


-(void)findContacts
{
    if (_foundEmailFriends) {
        return;
    }
    _foundEmailFriends = [@[] mutableCopy];
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
    }
    int numItems = MIN(index + PAGING, emailList.count) - index;
    NSArray *subList = [emailList subarrayWithRange:NSMakeRange(index, numItems)];
    [[TPOAuthClient sharedClient] findFriendsWithEmail:subList WithCompletionHandlersSuccess:^(NSArray *newUsers) {
        [self startPagingEmailList:emailList startingAtIndex:index + PAGING];
        [_foundEmailFriends addObjectsFromArray:newUsers];
        [self.tableView reloadData];
    } andFailure:^{
    }];
}

-(void)startPagingFacebookList:(NSArray *)fbList startingAtIndex:(int)index
{
    if (index > fbList.count) {
        return;
    }
    int numItems = MIN(index + PAGING, fbList.count) - index;
    NSArray *subList = [fbList subarrayWithRange:NSMakeRange(index, numItems)];
    [[TPOAuthClient sharedClient] findFriendsWithFacebookIds:subList WithCompletionHandlersSuccess:^(NSArray *newUsers) {
        [self startPagingFacebookList:fbList startingAtIndex:index + PAGING];
        [_foundFacebookFriends addObjectsFromArray:newUsers];
        [self.tableView reloadData];
    } andFailure:^{
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.findFriendsMode) {
        case TPFindFriendsViewModeContacts:
        {
            return [_foundEmailFriends count];
        }
            break;
        case TPFindFriendsViewModeFacebook:
        {
            return [_foundFacebookFriends count];
        }
            break;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPFindFriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *friend;
    switch (self.findFriendsMode) {
        case TPFindFriendsViewModeContacts:
        {
            friend = _foundEmailFriends[indexPath.row];
            cell.addButton.selected = [_selectedEmailFriends containsObject:friend];
        }
            break;
        case TPFindFriendsViewModeFacebook:
        {
            friend = _foundFacebookFriends[indexPath.row];
            cell.addButton.selected = [_selectedFacebookFriends containsObject:friend];
        }
            break;
        default:
            break;
    }
    cell.usernameLabelView.text = friend[@"email"];
    [cell.profilePictureView setImageWithURL:[NSURL URLWithString:friend[@"image"]]];
    cell.profilePictureView.layer.cornerRadius = cell.profilePictureView.bounds.size.height / 2;
    cell.profilePictureView.clipsToBounds = YES;
    [cell.addButton addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.addButton.tag = TAG_OFFSET + indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)addFriend:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag - TAG_OFFSET inSection:0];

    switch (self.findFriendsMode) {
        case TPFindFriendsViewModeContacts:
        {
            NSDictionary *friend = _foundEmailFriends[indexPath.row];
            if ([_selectedEmailFriends containsObject:friend]) {
                [_selectedEmailFriends removeObject:friend];
            } else {
                [_selectedEmailFriends addObject:friend];
            }
        }
            break;
        case TPFindFriendsViewModeFacebook:
        {
            NSDictionary *friend = _foundFacebookFriends[indexPath.row];
            if ([_selectedFacebookFriends containsObject:friend]) {
                [_selectedFacebookFriends removeObject:friend];
            } else {
                [_selectedFacebookFriends addObject:friend];
            }

        }
            break;
        default:
            break;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *friend;
    switch (self.findFriendsMode) {
        case TPFindFriendsViewModeContacts:
        {
            friend = _foundEmailFriends[indexPath.row];
        }
            break;
        case TPFindFriendsViewModeFacebook:
        {
            friend = _foundFacebookFriends[indexPath.row];
        }
            break;
        default:
            break;
    }
    TPUserProfileViewController *vc = [[TPUserProfileViewController alloc] init];
    vc.userId = friend[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)addButtonPressed:(id)sender {
    [self addAllFriends];
}

- (void)dismissSelf
{
    [self addSelectedFriends];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)addSelectedFriends
{
    NSMutableArray *friendsToAdd = [@[] mutableCopy];
    [friendsToAdd addObjectsFromArray:_selectedFacebookFriends];
    [friendsToAdd addObjectsFromArray:_selectedEmailFriends];
    if (friendsToAdd.count) {
        [[TPOAuthClient sharedClient] inviteFriends:friendsToAdd WithCompletionHandlersSuccess:^{
            NSLog(@"added");
        } andFailure:^{
        }];
    }
}

-(void)addAllFriends
{
    switch (self.findFriendsMode) {
    case TPFindFriendsViewModeContacts:
    {
        _selectedEmailFriends = [_foundEmailFriends mutableCopy];
    }
        break;
    case TPFindFriendsViewModeFacebook:
    {
        _selectedFacebookFriends = [_foundFacebookFriends mutableCopy];
    }
        break;
    default:
        break;
    }
    [self.tableView reloadData];
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}
@end
