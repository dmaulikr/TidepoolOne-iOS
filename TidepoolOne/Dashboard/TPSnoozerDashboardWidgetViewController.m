//
//  TPSnoozerDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerDashboardWidgetViewController.h"

@interface TPSnoozerDashboardWidgetViewController ()
{
    NSDateFormatter *_hourFromDate;
    int _numServerCallsCompleted;
}
@end

@implementation TPSnoozerDashboardWidgetViewController

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
    // Do any additional setup after loading the view from its nib.
    _hourFromDate = [[NSDateFormatter alloc] init];
    [_hourFromDate setDateFormat:@"HH"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(790, 192);
    NSDate *now = [NSDate date];
    int hour = [[_hourFromDate stringFromDate:now] floatValue];
    float offset = 790*hour/24;
    if (offset > (790-320)) {
        offset = 790-320;
    }
    self.scrollView.contentOffset = CGPointMake(offset, 0);
    self.scrollView.scrollEnabled = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self dismissPopovers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissPopovers
{
    //TODO: implement
}


-(void)downloadResults
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=SpeedArchetypeResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"results: %@", [responseObject[@"data"] description]);
        self.results = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
//            [_myRefreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
//        [_myRefreshControl endRefreshing];
    }];
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"user: %@", [responseObject[@"data"] description]);
        self.user = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
//            [_myRefreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
//        [_myRefreshControl endRefreshing];
    }];
    
    
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
            self.curveGraphView.data = scoresByHour;
            self.densityData = timesPlayedArray;
            self.results = scoresByHour;
            self.allTimeBestLabel.text = aggregateResults[0][@"high_scores"][@"all_time_best"];
            self.dailyBestLabel.text = aggregateResults[0][@"high_scores"][@"daily_best"];
        }
    }
}

-(void)reset
{
    self.allTimeBestLabel.text = @"";
    self.dailyBestLabel.text = @"";
    self.densityData = nil;
    self.curveGraphView.data = nil;
    self.results = nil;
}

@end
