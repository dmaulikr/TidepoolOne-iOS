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
#import "TPGamePickerCell.h"
#import "TPEchoGameViewController.h"

@interface TPGamePickerViewController () <UITableViewDelegate>
{
    NSDictionary *_gameClasses;
    NSDictionary *_gameCellImages;
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
    [self.tableView registerClass:[TPGamePickerCell class] forCellReuseIdentifier:@"GameCell"];
    self.title = @"Games";
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"games-bg.png"]];
    self.games = @[@"Snoozer", @"EI", @"Echo"];
    self.tableView.delegate = self;
    _gameClasses = @{
                     @"Snoozer":[TPSnoozerGameViewController class],
                     @"EI":[TPEIGameViewController class],
                     @"Echo":[TPEchoGameViewController class],
                     };
    _gameCellImages = @{
                     @"Snoozer":[UIImage imageNamed:@"cell-snoozer.png"],
                     @"EI":[UIImage imageNamed:@"cell-faceoff.png"],
                     @"Echo":[UIImage imageNamed:@"cell-echo.png"],
                     };
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
    } else {
        // iOS 7+
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
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
    static NSString *CellIdentifier = @"GameCell";
    TPGamePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSString *game = self.games[indexPath.row];
    cell.cellImageView.image = _gameCellImages[game];
//    cell.cellImageView.bounds = CGRectMake(0, 0, cell.cellImageView.bounds.size.width, 120);
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
