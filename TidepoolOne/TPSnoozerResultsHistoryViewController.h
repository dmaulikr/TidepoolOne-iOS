//
//  TPSnoozerResultsHistoryViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPResultsHistoryViewController.h"

@interface TPSnoozerResultsHistoryViewController : UITableViewController

@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) NSDictionary *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;

@end
