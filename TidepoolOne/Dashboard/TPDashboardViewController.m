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
#import "TPDashboardTableCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TPDashboardDetailViewController.h"

@interface TPDashboardViewController ()
{
    UIView *_dashboardHeaderView;
    int _numWidgetsCompleted;
    NSArray *_widgets;
    NSDictionary *_widgetVCs;
    NSDictionary *_labels;
    NSDictionary *_bottomLabels;
    BOOL _downloading;
}
@end

@implementation TPDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _downloading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    _dashboardHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self constructHeaderView];
    
    _widgets = @[@"snoozer",@"faceoff",@"fitbit"];
    _widgetVCs = @{@"snoozer":[[TPSnoozerDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil],
                   @"fitbit":[[TPFitbitDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil],
                   };
    _labels = @{@"snoozer":@[@"",@"Best of the day", @"All time best"],@"faceoff":@[@"",@"Best of the day", @"All time best"],@"fitbit":@[@"Speed",@"Activity",@"Sleep"]};
    _bottomLabels = @{@"snoozer":@[@"",@"POINTS", @"POINTS"],@"faceoff":@[@"",@"POINTS", @"POINTS"],@"fitbit":@[@"",@"",@""]};
    self.title = @"Dashboard";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TPDashboardTableCell class] forCellReuseIdentifier:@"TPDashboardTableCell"];
    [self.tableView reloadData];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];

    
//    self.tableView.tableHeaderView = _dashboardHeaderView;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
    } else {
        // iOS 7+
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
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
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Dashboard Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Dashboard Screen Appeared"];
#endif

}

-(void)constructHeaderView
{
//    self.snoozerWidget = [[TPSnoozerDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil];
//    [self addChildViewController:self.snoozerWidget];
//    [self.snoozerWidget didMoveToParentViewController:self];
//    [_dashboardHeaderView addSubview:self.snoozerWidget.view];
    
//    self.fitbitWidget = [[TPFitbitDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil];
//    [self addChildViewController:self.fitbitWidget];
//    [self.fitbitWidget didMoveToParentViewController:self];
//    self.fitbitWidget.view.frame = CGRectOffset(self.fitbitWidget.view.frame, 0, self.snoozerWidget.view.frame.size.height);
//    [_dashboardHeaderView addSubview:self.fitbitWidget.view];
    
//    CGRect bounds = _dashboardHeaderView.bounds;
//    bounds.size.height = self.snoozerWidget.view.frame.size.height + self.fitbitWidget.view.frame.size.height;
//    _dashboardHeaderView.bounds = bounds;
    
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
    for (NSString *key in _widgetVCs) {
        TPDashboardWidgetViewController *widget = _widgetVCs[key];
        [widget reset];
    }
    [self.tableView reloadData];
}

-(void)downloadResults
{
    if (_downloading) {
        return;
    }
    _downloading = YES;
    NSLog(@"start refresh");
    _numWidgetsCompleted = 0;
    for (NSString *key in _widgetVCs) {
        TPDashboardWidgetViewController *widget = _widgetVCs[key];
        [widget downloadResultswithCompletionHandlersSuccess:^{
            _numWidgetsCompleted++;
            NSLog(@"one more done");
            if (_numWidgetsCompleted == _widgetVCs.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"end refresh");
                    _downloading = NO;
                    [self.refreshControl endRefreshing];
                    [self.tableView reloadData];
                });
            }
        } andFailure:^{
            NSLog(@"error!");
            [self.refreshControl endRefreshing];
        }];

    }
    
//    [self.snoozerWidget downloadResultswithCompletionHandlersSuccess:^{
//        self.results = self.snoozerWidget.results;
//        _numWidgetsCompleted++;
//        NSLog(@"one more done - snoozer");
//        if (_numWidgetsCompleted == 2) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"end refresh");
//                _downloading = NO;
//                [self.refreshControl endRefreshing];
//            });
//        }
//    } andFailure:^{
//        NSLog(@"error!");
//        [self.refreshControl endRefreshing];
//    }];
//    [self.fitbitWidget downloadResultswithCompletionHandlersSuccess:^{
//        _numWidgetsCompleted++;
//        NSLog(@"one more done - fitbit");
//        if (_numWidgetsCompleted == 2) {
//            NSLog(@"end refresh");
//            _downloading = NO;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//            });
//        }
//    } andFailure:^{
//        NSLog(@"error!");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.refreshControl endRefreshing];
//        });
//    }];
}
//
//-(void)setResults:(NSArray *)results
//{
//    _results = [[results reverseObjectEnumerator] allObjects];
//    [self.tableView reloadData];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TPDashboardTableCell";
    TPDashboardTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.name = _widgets[indexPath.row];
    cell.labels = _labels[cell.name];
    cell.bottomLabels = _bottomLabels[cell.name];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *user = [TPOAuthClient sharedClient].user;
    
    if (user) {
        NSArray *aggregateResults = user[@"aggregate_results"];
        NSDictionary *activityAggregateResult = [self getAggregateScoreOfType:@"ActivityAggregateResult" fromArray:aggregateResults];
        NSDictionary *sleepAggregateResult = [self getAggregateScoreOfType:@"SleepAggregateResult" fromArray:aggregateResults];
        NSDictionary *speedAggregateResult = [self getAggregateScoreOfType:@"SpeedAggregateResult" fromArray:aggregateResults];
        if ([cell.name isEqualToString:@"snoozer"]) {
            NSDictionary *highScores = speedAggregateResult[@"high_scores"];
            cell.values = @[
                            @"",
                            [NSString stringWithFormat:@"%@",highScores[@"daily_best"]],
                            [NSString stringWithFormat:@"%@",highScores[@"all_time_best"]],
                            ];
//            cell.images = @[@0,@0,@0,];
        }
        else if ([cell.name isEqualToString:@"faceoff"]) {
//            cell.values = @[@"",highScores[@"daily_best"],highScores[@"all_time_best"] stringValue]];
//            cell.images = @[@0,@0,@0,];
        }
        else if ([cell.name isEqualToString:@"fitbit"]) {
            cell.values = @[
                            [NSString stringWithFormat:@"%i %%",(int)(100*[speedAggregateResult[@"scores"][@"trend"] floatValue])],
                            [NSString stringWithFormat:@"%i %%",(int)(100*[activityAggregateResult[@"scores"][@"trend"] floatValue])],
                            [NSString stringWithFormat:@"%i %%",(int)(100*[sleepAggregateResult[@"scores"][@"trend"] floatValue])],
                            ];
//            cell.images = @[@0,@0,@0,];
        }
    }
    return cell;
//    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPSnoozerResultsDashboardWidget" owner:nil options:nil];
//    TPSnoozerResultsDashboardWidget *view;
//    
//    for (id item in nibItems) {
//        if ([item isKindOfClass:[TPSnoozerResultsDashboardWidget class]]) {
//            view = item;
//        }
//    }
//    
//    view.frame = cell.contentView.frame;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
//    NSLocale *locale = [[NSLocale alloc]
//                        initWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setLocale:locale];
//    // below is hack for pre-iOS 7
//    NSMutableString *dateString = [self.results[indexPath.row][@"time_played"] mutableCopy];
//    if ([dateString characterAtIndex:26] == ':') {
//        [dateString deleteCharactersInRange:NSMakeRange(26, 1)];
//    }
//    
//    NSDate *date = [dateFormatter dateFromString:dateString];
//    view.date = date;
//    view.fastestTime = self.results[indexPath.row][@"speed_score"];
//    view.animalLabel.text = [self.results[indexPath.row][@"speed_archetype"] uppercaseString];
//    if ([view.animalLabel.text hasPrefix:@"PROGRESS"]) {
//        view.animalLabel.text = @"";
//    }
//    
//    view.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"anim-badge-%@.png", self.results[indexPath.row][@"speed_archetype"]]];
//    [[cell.contentView subviews]
//     makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [cell.contentView addSubview:view];
//    view.detailLabel.text = self.results[indexPath.row][@"description"];
//    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
//}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPDashboardWidgetViewController *widget = _widgetVCs[_widgets[indexPath.row]];
//    [widget downloadResultswithCompletionHandlersSuccess:^{
//        [self.navigationController pushViewController:widget animated:YES];
//    } andFailure:^{
//        NSLog(@"ERROR");
//    }];
    TPDashboardDetailViewController *detailVC = [[TPDashboardDetailViewController alloc] init];
    detailVC.widget = widget;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119;
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
    return _widgets.count;
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

-(NSDictionary *)getAggregateScoreOfType:(NSString *)type fromArray:(NSArray *)array
{
    for (NSDictionary *item in array) {
        if ([item[@"type"] isEqualToString:type]) {
            return item;
        }
    }
    return nil;
}

@end
