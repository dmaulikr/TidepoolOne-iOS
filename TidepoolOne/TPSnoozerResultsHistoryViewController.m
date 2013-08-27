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
#import "TPDashboardHeaderView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>

@interface TPSnoozerResultsHistoryViewController ()
{
    TPDashboardHeaderView *_dashboardHeaderView;
    
}
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
    self.title = @"Dashboard";
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];

    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPDashboardHeaderView" owner:nil options:nil];
    NSLog([nibItems description]);
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPDashboardHeaderView class]]) {
            _dashboardHeaderView = item;
        }
    }
    self.tableView.tableHeaderView = _dashboardHeaderView;
    
    __block TPSnoozerResultsHistoryViewController *wself = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wself downloadResults];
    }];
    [self.tableView triggerPullToRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    //hack, more to model
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Got New Game Results" object:nil];
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
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

-(void)setResults:(NSArray *)results
{
    _results = [[results reverseObjectEnumerator] allObjects];
    if (_results) {
        int dailyBest = 1000000;
        int allTimeBest = 1000000;
        NSDate *now = [NSDate date];
        for (NSDictionary *item in results) {
            NSDate *gameDate = [[TPOAuthClient sharedClient] dateFromString:item[@"time_played"]];
            int avgTime = [item[@"average_time"] intValue];
            if (avgTime != 0) {
                if (avgTime < allTimeBest) {
                    allTimeBest = avgTime;
                }
                if (avgTime < dailyBest && [self isSameDayWithDate1:gameDate date2:now]) {
                    dailyBest = avgTime;
                }
            }
        }
        _dashboardHeaderView.dailyBestLabel.text = [NSString stringWithFormat:@"%i", dailyBest];
        _dashboardHeaderView.allTimeBestLabel.text = [NSString stringWithFormat:@"%i", allTimeBest];
    }
    [self.tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _dashboardHeaderView.scrollView.contentSize = CGSizeMake(790, 192);
    _dashboardHeaderView.scrollView.scrollEnabled = YES;
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
    view.fastestTime = self.results[indexPath.row][@"average_time"];
    view.animalLabel.text = [self.results[indexPath.row][@"speed_archetype"] uppercaseString];
    view.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"anim-badge-%@.png", self.results[indexPath.row][@"speed_archetype"]]];
    [[cell.contentView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell.contentView addSubview:view];
    view.detailLabel.text = [self.results[indexPath.row][@"bullet_description"] componentsJoinedByString:@" "];
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

- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


@end
