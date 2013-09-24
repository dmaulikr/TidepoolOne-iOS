//
//  TPGamePickerViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGamePickerViewController.h"
#import "TPSnoozerGameViewController.h"
#import "TPEIGameViewController.h"

@interface TPGamePickerViewController () <UITableViewDelegate>
{
    NSDictionary *_gameClasses;
}
@end

@implementation TPGamePickerViewController

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
    self.games = @[@"Snoozer", @"EI"];
    self.tableView.delegate = self;
    _gameClasses = @{
                     @"Snoozer":[TPSnoozerGameViewController class],
                     @"EI":[TPEIGameViewController class],
                     };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.games[indexPath.row];
    // Configure the cell...
    return cell;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class gameClass = _gameClasses[_games[indexPath.row]];
    TPGameViewController *gameVC = [[gameClass alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:gameVC animated:YES];
}
@end
