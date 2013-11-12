//
//  TPFindFriendsViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/4/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPFindFriendsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSelector;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)dismissView:(id)sender;
@end
