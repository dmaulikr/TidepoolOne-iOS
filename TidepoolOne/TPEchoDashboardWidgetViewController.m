//
//  TPEchoDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/14/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoDashboardWidgetViewController.h"
#import "TPSnoozerResultCell.h"
#import "TPCircadianTooltipView.h"
#import "TPCurveGraphView.h"

@interface TPEchoDashboardWidgetViewController ()
{
    NSDateFormatter *_hourFromDate;
    int _numServerCallsCompleted;
    UIImageView *_legendView;
    TPCircadianTooltipView *_tooltipView;
    BOOL _gettingMoreResults;
    TPUser *_user;
}
@end

@implementation TPEchoDashboardWidgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
        self.type = @"AttentionResult";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TPDashboardTableCell";
    [tableView registerNib:[UINib nibWithNibName:@"TPSnoozerResultCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    TPSnoozerResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
    cell.date = date;
    cell.fastestTime = self.results[indexPath.row][@"attention_score"];
    cell.animalLabel.text = [self.results[indexPath.row][@"badge"][@"title"] uppercaseString];
    if ([cell.animalLabel.text hasPrefix:@"PROGRESS"]) {
        cell.animalLabel.text = @"";
    }
    
    cell.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"echo-badge-%@.png", self.results[indexPath.row][@"badge"][@"character"]]];
    cell.detailLabel.text = self.results[indexPath.row][@"badge"][@"description"];
    [cell adjustScrollView];
    
    if (indexPath.row > self.results.count - 3) {
        [self getMoreResults];
    }
    
    return cell;
}

-(void)setUser:(TPUser *)user
{
    _user = user;
    if (_user) {
        @try {
            NSArray *aggregateResults = _user.aggregateResults;
            if (aggregateResults.count) {
                NSDictionary *speedAggregateResult = [_user aggregateResultOfType:@"AttentionAggregateResult"];
                NSDictionary *circadianRhythm = speedAggregateResult[@"scores"][@"circadian"];
                NSMutableArray *timesPlayedArray = [NSMutableArray array];
                NSMutableArray *scoresByHour = [NSMutableArray array];
                for (int i=0;i<24;i++) {
                    NSDictionary *hourlyDetail = circadianRhythm[[NSString stringWithFormat:@"%i",i]];
                    [scoresByHour addObject:hourlyDetail[@"score"]];
                    [timesPlayedArray addObject:hourlyDetail[@"times_played"]];
                }
                self.curveGraphView.data = scoresByHour;
                self.densityData = timesPlayedArray;
                self.allTimeBestLabel.text = speedAggregateResult[@"high_scores"][@"all_time_best"];
                self.dailyBestLabel.text = speedAggregateResult[@"high_scores"][@"daily_best"];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }
    }
}

-(TPUser *)user
{
    return _user;
}

-(void)setDensityData:(NSArray *)densityData
{
    _densityData = densityData;
    UIImage *high = [UIImage imageNamed:@"dash-density-green.png"];
    UIImage *medium = [UIImage imageNamed:@"dash-density-yellow.png"];
    UIImage *low = [UIImage imageNamed:@"dash-density-red.png"];
    if (_densityData) {
        for (int i=0;i<_densityData.count;i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(i-0.5), 44, 66, 10)];
            int timesPlayed = [_densityData[i] intValue];
            if (timesPlayed <= 3) {
                imageView.image = low;
            } else if (timesPlayed <= 5) {
                imageView.image = medium;
            } else if (timesPlayed > 5) {
                imageView.image = high;
            }
            [self.scrollView addSubview:imageView];
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
