//
//  TPUserProfileViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPUserProfileViewController : UIViewController

@property (strong, nonatomic) NSString *userId;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDictionary *user;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *profileView;

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIImageView *personalityBadgeView;
@property (weak, nonatomic) IBOutlet UITextView *blurbView;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UILabel *personalityLabelView;
@property (weak, nonatomic) IBOutlet UIButton *addToFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
- (IBAction)addToFriendsButtonPressed:(UIButton *)sender;

- (IBAction)acceptFriendPressed:(id)sender;
- (IBAction)rejectFriendPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *pendingFriendLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectFriendButton;
@end
