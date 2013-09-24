//
//  TPDashboardViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerDashboardWidgetViewController.h"
#import "TPFitbitDashboardWidgetViewController.h"

@interface TPDashboardViewController : UITableViewController

@property (strong, nonatomic) NSArray *results;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;
@property (strong, nonatomic) TPSnoozerDashboardWidgetViewController *snoozerWidget;
@property (strong, nonatomic) TPFitbitDashboardWidgetViewController *fitbitWidget;

@end
