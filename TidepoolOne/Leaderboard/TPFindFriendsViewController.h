//
//  TPFindFriendsViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/4/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TPFindFriendsViewMode {TPFindFriendsViewModeContacts, TPFindFriendsViewModeFacebook} TPFindFriendsViewMode;

@interface TPFindFriendsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSelector;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) TPFindFriendsViewMode findFriendsMode;

- (IBAction)addButtonPressed:(id)sender;

@end
