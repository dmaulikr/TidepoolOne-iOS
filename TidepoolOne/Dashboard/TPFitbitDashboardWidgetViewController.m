//
//  TPFitbitDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFitbitDashboardWidgetViewController.h"
#import "TPServiceLoginViewController.h"
#import <AFHTTPRequestOperation.h>

@interface TPFitbitDashboardWidgetViewController()
{
    int _numServerCallsCompleted;
    CGSize _connectedSize;
    CGSize _notConnectedSize;
    TPOAuthClient *_oauthClient;
    __block NSTimer *_pollTimeoutTimer;
    __block NSTimer *_pollTimer;
}
@end

@implementation TPFitbitDashboardWidgetViewController

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
    _oauthClient = [TPOAuthClient sharedClient];
    self.fitbitBarGraphView.unselectedColor = [UIColor colorWithRed:63/255.0 green:201/255.0 blue:167/255.0 alpha:1.0];
    self.fitbitActivityGraphView.color = [UIColor colorWithRed:250/255.0 green:187/255.0 blue:61/255.0 alpha:1.0];
    self.fitbitSleepGraphView.color = [UIColor colorWithRed:2/255.0 green:110/255.0 blue:160/255.0 alpha:1.0];
    _connectedSize = self.view.bounds.size;
    _notConnectedSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - self.fitbitScrollView.frame.size.height);
    self.speedChange = 0;
    self.sleepChange = 0;
    self.activityChange = 0;
    
    [self refreshFitbitConnectedness];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.fitbitScrollView.contentSize = CGSizeMake(694, 244);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setIsConnected:(BOOL)isConnected
{
    _isConnected = isConnected;
    if (!isConnected) {
        self.view.hidden = NO;
    } else {
        self.view.hidden = YES;
    }
}

-(void)refreshFitbitConnectedness
{
    // TODO: create method on oauthclient that will get used and run code
    NSDictionary *user = [TPOAuthClient sharedClient].user;
    NSArray *authentications = user[@"authentications"];
    self.isConnected = NO;
    for (NSDictionary *item in authentications) {
        if ([item[@"provider"] isEqualToString:@"fitbit"]) {
            self.isConnected = YES;
        }
    }
}

-(void)pollTimedOut
{
    [_pollTimer invalidate];
    _pollTimer = nil;
    [[[UIAlertView alloc] initWithTitle:@"Server busy" message:@"Fitbit sync is taking too long. When synced, they will be populated on the dashboard." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void)pollForFitbitSyncStatus
{
    NSLog(@"continue poll");
    [_oauthClient getPath:@"api/v1/users/-/connections/fitbit/progress.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *status = responseObject[@"status"];
        NSString *state = status[@"state"];
        if ([state isEqualToString:@"pending"]) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pollForFitbitSyncStatus) userInfo:nil repeats:NO];
        } else if ([state isEqualToString:@"done"]){
            [_pollTimeoutTimer invalidate];
            _pollTimeoutTimer = nil;
            NSLog(@"poll done");
            [self refreshWeeklyDatawithCompletionHandlersSuccess:^{
                [_pollTimeoutTimer invalidate];
                _pollTimeoutTimer = nil;
            } andFailure:^{
                [_pollTimeoutTimer invalidate];
                _pollTimeoutTimer = nil;
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Fitbit data could not be refreshed at this time. Please try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_oauthClient handleError:error withOptionalMessage:@"Could not refresh Fitbit"];
    }];
}


-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (_user) {
        [self refreshFitbitConnectedness];
        @try {
            NSArray *aggregateResults = _user[@"aggregate_results"];
            if (aggregateResults.count && (aggregateResults != (NSArray *)[NSNull null])) {
                NSDictionary *activityAggregateResult = [self getAggregateScoreOfType:@"ActivityAggregateResult" fromArray:aggregateResults];
                NSDictionary *sleepAggregateResult = [self getAggregateScoreOfType:@"SleepAggregateResult" fromArray:aggregateResults];
                NSDictionary *speedAggregateResult = [self getAggregateScoreOfType:@"SpeedAggregateResult" fromArray:aggregateResults];
                
                NSArray *stepsRhythm = activityAggregateResult[@"scores"][@"weekly"];
                NSMutableArray *stepsWeekly = [NSMutableArray array];
                for (int i=0; i < stepsRhythm.count; i++) {
                    [stepsWeekly addObject:stepsRhythm[i][@"average"]];
                }
                
                NSArray *sleepRhythm = sleepAggregateResult[@"scores"][@"weekly"];
                NSMutableArray *sleepWeekly = [NSMutableArray array];
                for (int i=0; i < sleepRhythm.count; i++) {
                    [sleepWeekly addObject:sleepRhythm[i][@"average"]];
                }
                
                NSArray *speedRhythm = speedAggregateResult[@"scores"][@"weekly"];
                NSMutableArray *speedWeekly = [NSMutableArray array];
                for (int i=0; i < speedRhythm.count; i++) {
                    [speedWeekly addObject:speedRhythm[i][@"average_speed_score"]];
                }

                
                self.fitbitSleepGraphView.data = sleepWeekly;
                self.fitbitActivityGraphView.data = stepsWeekly;
                self.fitbitBarGraphView.data = speedWeekly;
                self.speedChange = [speedAggregateResult[@"scores"][@"trend"] floatValue];
                self.activityChange = [activityAggregateResult[@"scores"][@"trend"] floatValue];
                self.sleepChange = [sleepAggregateResult[@"scores"][@"trend"] floatValue];
            }
        }
        @catch (NSException *e) {
            NSLog([e description]);
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

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    [self refreshWeeklyDatawithCompletionHandlersSuccess:successBlock andFailure:failureBlock];
    if (self.isConnected) {
        [self refreshFitbitData];
    }
}
    
-(void)refreshWeeklyDatawithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock
{
    _numServerCallsCompleted = 0;    
    NSLog(@"refresh weekly data - start");
    // NEW WAY - DOESNT WORK - INFINITELY CALLED.. PROBABLY AN ISSUE WITH BLOCK VARIABLES//

//    [[TPOAuthClient sharedClient] getUserInfoFromServerWithCompletionHandlersSuccess:^{
//        self.user = [TPOAuthClient sharedClient].user;
//        _numServerCallsCompleted++;
//        if (_numServerCallsCompleted == 1) {
//            successBlock();
//        }
//    } andFailure:^{
//        failureBlock();
//    }];
    //END NEW WAY//
    //OLD WAY//
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"refresh weekly data - end");
        [TPOAuthClient sharedClient].user = responseObject[@"data"];
        self.user = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 1) {
            NSLog(@"refresh weekly data - end - stop refresh");
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        failureBlock();
    }];
    // END OLD WAY//
}

-(void)refreshFitbitData
{
    NSLog(@"start fitbit refresh");
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/connections/fitbit/synchronize.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *status = responseObject[@"status"];
        if ([status[@"state"] isEqualToString:@"pending"]) {
            NSLog(@"start poll");
            _pollTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollTimedOut) userInfo:nil repeats:NO];
            [self pollForFitbitSyncStatus];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not update fitbit data"];
    }];
}


-(void)setSleepChange:(float)sleepChange
{
    _sleepChange = sleepChange;
    [self setArrowImage:_sleepArrowImage withColorString:@"blue" andLabel:_sleepNumberLabel withValue:sleepChange];
}

-(void)setActivityChange:(float)activityChange
{
    _activityChange = activityChange;
    [self setArrowImage:_activityArrowImage withColorString:@"yellow" andLabel:_activityNumberLabel withValue:activityChange];}

-(void)setSpeedChange:(float)speedChange
{
    _speedChange = speedChange;
    [self setArrowImage:_speedArrowImage withColorString:@"green" andLabel:_speedNumberLabel withValue:speedChange];
}


-(void)setArrowImage:(UIImageView *)imageView withColorString:(NSString *)colorString andLabel:(UILabel *)label withValue:(float)value
{
    if (value > 1) {
        label.text = @">100%";
    } else if (value < -1) {
        label.text = @"<100%";
    } else {
        label.text = [NSString stringWithFormat:@"%i%%",(int)(100*fabs(value))];
    }
    if (value > 0) {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"fitbit-%@arrow-up.png", colorString]];
    } else if (value < 0) {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"fitbit-%@arrow-down.png", colorString]];
    } else if (!value) {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"fitbit-%@arrow.png", colorString]];
    }
}

@end
