//
//  TPSnoozerResultsHistoryViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultsHistoryViewController.h"
#import "TPSnoozerResultsHistoryWidget.h"

@interface TPSnoozerResultsHistoryViewController ()

@end

@implementation TPSnoozerResultsHistoryViewController

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
	// Do any additional setup after loading the view.
    self.navBar.topItem.title = @"Snoozer Results";
    self.results = @[@"ass"];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.contentView.backgroundColor = [UIColor yellowColor];
    TPSnoozerResultsHistoryWidget *view = [[NSBundle mainBundle] loadNibNamed:@"TPSnoozerResultsHistoryWidget" owner:nil options:nil][0];
    view.frame = cell.contentView.frame;
    view.date = [NSDate date];
    view.fastestTime = @345;
    
    [cell.contentView addSubview:view];
    // Configure the cell...
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
