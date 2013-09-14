//
//  TPDashboardViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardViewController.h"
#import "TPSnoozerResultsDashboardWidget.h"
#import "TPSnoozerResultViewController.h"
#import "TPDashboardHeaderView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TPServiceLoginViewController.h"

@interface TPDashboardViewController ()
{
    TPDashboardHeaderView *_dashboardHeaderView;
    int _numServerCallsCompleted;
    NSDateFormatter *_hourFromDate;
    UIRefreshControl *_myRefreshControl;
}
@end

@implementation TPDashboardViewController

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

    _dashboardHeaderView = [[TPDashboardHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 616)];
    self.tableView.tableHeaderView = _dashboardHeaderView;
    
    _myRefreshControl = [[UIRefreshControl alloc]
                                        init];
    [_myRefreshControl addTarget:self action:@selector(downloadResults) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_myRefreshControl];

    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    //hack, more to model
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Got New Game Results" object:nil];
    
    _hourFromDate = [[NSDateFormatter alloc] init];
    [_hourFromDate setDateFormat:@"HH"];
    
    [self loggedIn];
}



-(void)loggedIn
{
    [self.tableView setContentOffset:CGPointMake(0, -_myRefreshControl.frame.size.height) animated:YES];
    [_myRefreshControl beginRefreshing];
    [self downloadResults];
}

-(void)loggedOut
{
    _dashboardHeaderView.snoozerSummaryView.allTimeBestLabel.text = @"";
    _dashboardHeaderView.snoozerSummaryView.dailyBestLabel.text = @"";
    _dashboardHeaderView.snoozerSummaryView.densityData = nil;
    _dashboardHeaderView.snoozerSummaryView.curveGraphView.data = nil;
    self.results = nil;
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_dashboardHeaderView.snoozerSummaryView dismissPopovers];
}

-(void)downloadResults
{
    [self downloadResultsForSnoozerSummary];
    [self downloadResultsForFitbitSummary];
}

-(void)downloadResultsForSnoozerSummary
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=SpeedArchetypeResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"results: %@", [responseObject[@"data"] description]);
        self.results = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            [_myRefreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        [_myRefreshControl endRefreshing];
    }];
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"user: %@", [responseObject[@"data"] description]);
        self.user = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            [_myRefreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        [_myRefreshControl endRefreshing];
    }];

    
}

-(void)setResults:(NSArray *)results
{
    _results = [[results reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}

-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (_user) {
        NSArray *aggregateResults = _user[@"aggregate_results"];
        if (aggregateResults.count && (aggregateResults != (NSArray *)[NSNull null])) {
            NSDictionary *circadianRhythm = aggregateResults[0][@"scores"][@"circadian"];
            NSMutableArray *timesPlayedArray = [NSMutableArray array];
            NSMutableArray *scoresByHour = [NSMutableArray array];
            for (int i=0;i<24;i++) {
                NSDictionary *hourlyDetail = circadianRhythm[[NSString stringWithFormat:@"%i",i]];
                [scoresByHour addObject:hourlyDetail[@"speed_score"]];
                [timesPlayedArray addObject:hourlyDetail[@"times_played"]];
            }
            
            _dashboardHeaderView.snoozerSummaryView.curveGraphView.data = scoresByHour;
            _dashboardHeaderView.snoozerSummaryView.densityData = timesPlayedArray;
            _dashboardHeaderView.snoozerSummaryView.results = scoresByHour;
            _dashboardHeaderView.snoozerSummaryView.allTimeBestLabel.text = aggregateResults[0][@"high_scores"][@"all_time_best"];
            _dashboardHeaderView.snoozerSummaryView.dailyBestLabel.text = aggregateResults[0][@"high_scores"][@"daily_best"];
        }
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _dashboardHeaderView.snoozerSummaryView.scrollView.contentSize = CGSizeMake(790, 192);
    _dashboardHeaderView.fitbitSummaryView.fitbitScrollView.contentSize = CGSizeMake(694, 244);
    NSDate *now = [NSDate date];
    int hour = [[_hourFromDate stringFromDate:now] floatValue];
    float offset = 790*hour/24;
    if (offset > (790-320)) {
        offset = 790-320;
    }
    _dashboardHeaderView.snoozerSummaryView.scrollView.contentOffset = CGPointMake(offset, 0);
    _dashboardHeaderView.snoozerSummaryView.scrollView.scrollEnabled = YES;
    
    
    //TODO: working on graph params - remove and refactor later
    _dashboardHeaderView.fitbitSummaryView.fitbitActivityGraphView.data = @[@13, @52, @23, @44, @15, @26, @71];
    _dashboardHeaderView.fitbitSummaryView.fitbitSleepGraphView.data = @[@13, @52, @23, @44, @15, @126, @71];
    _dashboardHeaderView.fitbitSummaryView.fitbitSleepGraphView.color = [UIColor redColor];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SnoozerResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPSnoozerResultsDashboardWidget" owner:nil options:nil];
    TPSnoozerResultsDashboardWidget *view;
    
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPSnoozerResultsDashboardWidget class]]) {
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
    view.fastestTime = self.results[indexPath.row][@"speed_score"];
    view.animalLabel.text = [self.results[indexPath.row][@"speed_archetype"] uppercaseString];
    if ([view.animalLabel.text hasPrefix:@"PROGRESS"]) {
        view.animalLabel.text = @"";
    }
    
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

-(void)downloadResultsForFitbitSummary
{
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/sleeps" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
        NSLog(@"sucess:%i",[(NSArray *)responseObject[@"data"] count]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
    }];
    
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/activities" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
        NSLog(@"sucess:%i",[(NSArray *)responseObject[@"data"] count]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
    }];
    
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?daily=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
    }];
    
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
