//
//  TPDashboardDetailViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/9/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardDetailViewController.h"

@interface TPDashboardDetailViewController ()

@end

@implementation TPDashboardDetailViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
//    imgView.frame = self.view.frame;
    self.tableView.backgroundView = imgView;
    [self addChildViewController:self.widget];
    self.tableView.tableHeaderView = self.widget.view;
    [self didMoveToParentViewController:self];
    self.tableView.dataSource = self.widget;
    self.tableView.delegate = self.widget;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
