//
//  TPDashboardViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardViewController.h"
#import "TPSnoozerResultViewController.h"
#import "TPDashboardTableCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TPDashboardDetailViewController.h"
#import "TPSnoozerDashboardWidgetViewController.h"
#import "TPFitbitDashboardWidgetViewController.h"
#import "TPFaceoffDashboardWidgetViewController.h"

@interface TPDashboardViewController ()
{
    UIView *_dashboardHeaderView;
    int _numWidgetsCompleted;
    NSArray *_widgets;
    NSDictionary *_widgetVCs;
    NSDictionary *_labels;
    NSDictionary *_bottomLabels;
    BOOL _downloading;
    TPDashboardDetailViewController *_detailVC;
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
    
    _dashboardHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    [self constructHeaderView];
    
    _widgets = @[@"snoozer",@"faceoff",@"fitbit"];
    _widgetVCs = @{@"snoozer":[[TPSnoozerDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil],
                   @"faceoff":[[TPFaceoffDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil],
                   @"fitbit":[[TPFitbitDashboardWidgetViewController alloc] initWithNibName:nil bundle:nil],
                   };
    _labels = @{@"snoozer":@[@"",@"Best of the day", @"All time best"],@"faceoff":@[@"",@"Best of the day", @"All time best"],@"fitbit":@[@"Speed",@"Activity",@"Sleep"]};
    _bottomLabels = @{@"snoozer":@[@"",@"POINTS", @"POINTS"],@"faceoff":@[@"",@"POINTS", @"POINTS"],@"fitbit":@[@"",@"",@""]};
    self.title = @"Dashboard";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TPDashboardTableCell class] forCellReuseIdentifier:@"TPDashboardTableCell"];
    [self.tableView reloadData];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];

    
    self.tableView.tableHeaderView = _dashboardHeaderView;

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
}

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
        NSDictionary *emoAggregateResult = [self getAggregateScoreOfType:@"EmoAggregateResult" fromArray:aggregateResults];

        if ([cell.name isEqualToString:@"snoozer"]) {
            NSDictionary *highScores = speedAggregateResult[@"high_scores"];
            NSString *dailyBest;
            if (highScores[@"daily_best"] && highScores[@"daily_best"] != [NSNull null]) {
                dailyBest = highScores[@"daily_best"];
            } else {
                dailyBest = @"0";
            }
            NSString *allTimeBest;
            if (highScores[@"all_time_best"] && highScores[@"all_time_best"] != [NSNull null]) {
                allTimeBest = highScores[@"all_time_best"];
            } else {
                allTimeBest = @"0";
            }

            cell.values = @[
                            @"",
                            dailyBest,
                            allTimeBest,
                            ];
            UIImage *lastBadge = [UIImage imageNamed:[NSString stringWithFormat:@"anim-badge-%@.png", speedAggregateResult[@"badge"][@"character"]]];
            cell.imageView1.image = lastBadge;
            cell.imageView1.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }
        else if ([cell.name isEqualToString:@"faceoff"]) {
            NSDictionary *highScores = emoAggregateResult[@"high_scores"];
            NSString *dailyBest;
            if (highScores[@"daily_best"] && highScores[@"daily_best"] != [NSNull null]) {
                dailyBest = highScores[@"daily_best"];
            } else {
                dailyBest = @"0";
            }
            NSString *allTimeBest;
            if (highScores[@"all_time_best"] && highScores[@"all_time_best"] != [NSNull null]) {
                allTimeBest = highScores[@"all_time_best"];
            } else {
                allTimeBest = @"0";
            }
            
            cell.values = @[
                            @"",
                            dailyBest,
                            allTimeBest,
                            ];
            UIImage *lastBadge = [UIImage imageNamed:[NSString stringWithFormat:@"celeb-badge-%@.png", emoAggregateResult[@"badge"][@"character"]]];
            cell.imageView1.image = lastBadge;
            cell.imageView1.transform = CGAffineTransformMakeScale(0.6, 0.6);
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPDashboardWidgetViewController *widget = _widgetVCs[_widgets[indexPath.row]];
    _detailVC = [[TPDashboardDetailViewController alloc] init];
    _detailVC.widget = widget;
    [self.navigationController pushViewController:_detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TPFitbitDashboardWidgetViewController *fitbitVC = (TPFitbitDashboardWidgetViewController *)_widgetVCs[@"fitbit"];
    return _widgets.count - 1 + fitbitVC.isConnected;
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
