//
//  TPSnoozerDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerDashboardWidgetViewController.h"
#import "TPCircadianTooltipView.h"

@interface TPSnoozerDashboardWidgetViewController ()
{
    NSDateFormatter *_hourFromDate;
    int _numServerCallsCompleted;
    UIImageView *_legendView;
    TPCircadianTooltipView *_tooltipView;
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
    UIImage *image = [UIImage imageNamed:@"dash-densityflag2.png"];
    _legendView = [[UIImageView alloc] initWithImage:image];
    _legendView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    _legendView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
    [self.view addGestureRecognizer:tap];
    
    
    _tooltipView = [[TPCircadianTooltipView alloc] initWithFrame:CGRectMake(0, 0, 85, 61)];
    _tooltipView.hidden = YES;
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


-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=SpeedArchetypeResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.results = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        failureBlock();
    }];
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TPOAuthClient sharedClient].user = responseObject[@"data"];
        self.user = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        failureBlock();
    }];
}

-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (_user) {
        @try {
            NSArray *aggregateResults = _user[@"aggregate_results"];
            if (aggregateResults.count && (aggregateResults != (NSArray *)[NSNull null])) {
                NSDictionary *speedAggregateResult = [self getAggregateScoreOfType:@"SpeedAggregateResult" fromArray:aggregateResults];
                NSDictionary *circadianRhythm = speedAggregateResult[@"scores"][@"circadian"];
                NSMutableArray *timesPlayedArray = [NSMutableArray array];
                NSMutableArray *scoresByHour = [NSMutableArray array];
                for (int i=0;i<24;i++) {
                    NSDictionary *hourlyDetail = circadianRhythm[[NSString stringWithFormat:@"%i",i]];
                    [scoresByHour addObject:hourlyDetail[@"speed_score"]];
                    [timesPlayedArray addObject:hourlyDetail[@"times_played"]];
                }
                self.curveGraphView.data = scoresByHour;
                self.densityData = timesPlayedArray;
                self.allTimeBestLabel.text = aggregateResults[0][@"high_scores"][@"all_time_best"];
                self.dailyBestLabel.text = aggregateResults[0][@"high_scores"][@"daily_best"];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }
    }
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


-(void)reset
{
    self.allTimeBestLabel.text = @"";
    self.dailyBestLabel.text = @"";
    self.densityData = nil;
    self.curveGraphView.data = nil;
    self.results = nil;
}



-(void)viewWasTapped:(UIGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.scrollView];
    
    if (!_legendView.hidden || !_tooltipView.hidden) {
        [self dismissPopovers];
    } else {
        if (touchPoint.y < 58) {
            _legendView.hidden = NO;
            _legendView.center = CGPointMake(touchPoint.x + _legendView.bounds.size.width/2, 49);
            [self.scrollView addSubview:_legendView];
        } else if (touchPoint.y > 60) {
            if (self.results) {
                _tooltipView.hidden = NO;
                int index = [self indexForTouchPoint:touchPoint];
                float x = 32.5*index+22;
                if (index < 19) {
                    x++;
                }
                _tooltipView.center = CGPointMake(x, 100);
                _tooltipView.score = self.curveGraphView.data[index];
                [self.scrollView addSubview:_tooltipView];
            }
        }
    }
}


-(int)indexForTouchPoint:(CGPoint)touchPoint
{
    float index = 24 * touchPoint.x / 790;
    return (int)index;
}

-(void)dismissPopovers
{
    _legendView.hidden = YES;
    [_legendView removeFromSuperview];
    _tooltipView.hidden = YES;
    [_tooltipView removeFromSuperview];
}


@end
