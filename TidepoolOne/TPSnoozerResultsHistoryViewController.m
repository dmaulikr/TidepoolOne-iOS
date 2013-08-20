//
//  TPSnoozerResultsHistoryViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultsHistoryViewController.h"
#import "TPSnoozerResultsHistoryWidget.h"
#import "TPSnoozerResultViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>

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
    self.title = @"Snoozer Results";
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"results-bg.png"]];
    
    __block TPSnoozerResultsHistoryViewController *wself = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wself downloadResults];
    }];
    [self.tableView triggerPullToRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    //hack, more to model
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"New Game Finished" object:nil];
}

-(void)loggedIn
{
    [self.tableView triggerPullToRefresh];
}

-(void)loggedOut
{
    self.results = nil;
    [self.tableView reloadData];
}

-(void)downloadResults
{
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=SpeedArchetypeResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"results: %@", [responseObject[@"data"] description]);
        self.results = responseObject[@"data"];
        [self.tableView.pullToRefreshView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

-(void)setResults:(NSArray *)results
{
    _results = [[results reverseObjectEnumerator] allObjects];
    if (_results) {
        
    }
    [self.tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SnoozerResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPSnoozerResultsHistoryWidget" owner:nil options:nil];
    TPSnoozerResultsHistoryWidget *view;
    
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPSnoozerResultsHistoryWidget class]]) {
            view = item;
        }
    }
    
    view.frame = cell.contentView.frame;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    // below is hack for pre-iOS 7
    NSMutableString *dateString = [self.results[indexPath.row][@"time_played"] mutableCopy];
    if ([dateString characterAtIndex:26] == ':') {
        [dateString deleteCharactersInRange:NSMakeRange(26, 1)];
    }
                            
    NSDate *date = [dateFormatter dateFromString:dateString];
    view.date = date;
    view.fastestTime = self.results[indexPath.row][@"fastest_time"];
    view.animalLabel.text = [self.results[indexPath.row][@"speed_archetype"] uppercaseString];
    view.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"anim-badge-%@.png", self.results[indexPath.row][@"speed_archetype"]]];
    [[cell.contentView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:view];
    view.detailLabel.text = self.results[indexPath.row][@"description"];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//self.results.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
