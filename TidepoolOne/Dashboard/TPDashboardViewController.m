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
#import <MBProgressHUD/MBProgressHUD.h>

@interface TPDashboardViewController ()
{
    UIView *_dashboardHeaderView;
    int _numWidgetsCompleted;
    NSArray *_widgets;
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

    _dashboardHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self constructHeaderView];
    self.tableView.tableHeaderView = _dashboardHeaderView;
    
    self.refreshControl = [[UIRefreshControl alloc]
                                        init];
    [self.refreshControl addTarget:self action:@selector(downloadResults) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = self.refreshControl;
    self.tableView.backgroundView.layer.zPosition -= 1;


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    //hack, more to model
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Got New Game Results" object:nil];
    [self loggedIn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Dashboard Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];

}

-(void)constructHeaderView
{
    self.snoozerWidget = [[TPSnoozerDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.snoozerWidget];
    [self.snoozerWidget didMoveToParentViewController:self];
    [_dashboardHeaderView addSubview:self.snoozerWidget.view];
    
    self.fitbitWidget = [[TPFitbitDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.fitbitWidget];
    [self.fitbitWidget didMoveToParentViewController:self];
    self.fitbitWidget.view.frame = CGRectOffset(self.fitbitWidget.view.frame, 0, self.snoozerWidget.view.frame.size.height);
    [_dashboardHeaderView addSubview:self.fitbitWidget.view];
    
    CGRect bounds = _dashboardHeaderView.bounds;
    bounds.size.height = self.snoozerWidget.view.frame.size.height + self.fitbitWidget.view.frame.size.height;
    _dashboardHeaderView.bounds = bounds;
    
}



-(void)loggedIn
{
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
    });
    [self downloadResults];
}

-(void)loggedOut
{
    [self.snoozerWidget reset];
    [self.tableView reloadData];
}

-(void)downloadResults
{
    _numWidgetsCompleted = 0;
    [self.snoozerWidget downloadResultswithCompletionHandlersSuccess:^{
        self.results = self.snoozerWidget.results;
        _numWidgetsCompleted++;
        if (_numWidgetsCompleted == 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"end refresh");
                [self.refreshControl endRefreshing];
            });
        }
    } andFailure:^{
        [self.refreshControl endRefreshing];
    }];
    [self.fitbitWidget downloadResultswithCompletionHandlersSuccess:^{
        _numWidgetsCompleted++;
        if (_numWidgetsCompleted == 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }
    } andFailure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }];

}

-(void)setResults:(NSArray *)results
{
    _results = [[results reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
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

-(void)showFitbitConnect
{
    
}

@end
