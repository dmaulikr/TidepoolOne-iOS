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

@interface TPFitbitDashboardWidgetViewController()<TPServiceLoginViewControllerDelegate>
{
    int _numServerCallsCompleted;
    CGSize _connectedSize;
    CGSize _notConnectedSize;
    TPOAuthClient *_oauthClient;
    NSTimer *_pollTimeoutTimer;
    NSTimer *_pollTimer;
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
    [self refreshFitbitConnectedness];
    self.speedChange = 0;
    self.sleepChange = 0;
    self.activityChange = 0;
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
        self.connectView.hidden = NO;
    } else {
        self.connectView.hidden = YES;
    }
}

-(void)refreshFitbitConnectedness
{
    //TODO: centralize
    NSDictionary *user = [TPOAuthClient sharedClient].user;
    NSArray *authentications = user[@"authentications"];
    self.isConnected = NO;
    for (NSDictionary *item in authentications) {
        if ([item[@"provider"] isEqualToString:@"fitbit"]) {
            self.isConnected = YES;
        }
    }
}


-(void)showConnectUI
{
    TPServiceLoginViewController *serviceVC = [[TPServiceLoginViewController alloc] init];
    serviceVC.delegate = self;
    serviceVC.view.frame = self.view.bounds;
    [self.navigationController pushViewController:serviceVC animated:YES];
}

-(void)connectionMadeSucessfully:(BOOL)success
{
    [self.navigationController popViewControllerAnimated:YES];
    if (success) {
        [self downloadResultswithCompletionHandlersSuccess:^{
            [self refreshFitbitConnectedness];
        } andFailure:^{}];
    } else {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to Fitbit. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil] show];
    }
}


- (IBAction)connectAction:(id)sender
{
    [self showConnectUI];
}
- (IBAction)refreshButtonPressed:(id)sender
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = 2000;
    [self.refreshButton.layer addAnimation:animation forKey:@"MyAnimation"];

    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/connections/fitbit/synchronize.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *status = responseObject[@"status"];
        NSLog([status description]);
        if ([status[@"state"] isEqualToString:@"pending"]) {
            _pollTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollTimedOut) userInfo:nil repeats:NO];
            [self pollForFitbitSyncStatus];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshButton.layer removeAllAnimations];
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not update fitbit data"];
    }];

}

-(void)pollTimedOut
{
    [_pollTimer invalidate];
    _pollTimer = nil;
    [self.refreshButton.layer removeAllAnimations];
    [[[UIAlertView alloc] initWithTitle:@"Server busy" message:@"Fitbit sync is taking too long. When synced, they will be populated on the dashboard." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void)pollForFitbitSyncStatus
{
    [_oauthClient getPath:@"api/v1/users/-/connections/fitbit/progress.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *status = responseObject[@"status"];
        NSString *state = status[@"state"];
        if ([state isEqualToString:@"pending"]) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pollForFitbitSyncStatus) userInfo:nil repeats:NO];
        } else if ([state isEqualToString:@"done"]){
            [_pollTimeoutTimer invalidate];
            _pollTimeoutTimer = nil;
            [self downloadResultswithCompletionHandlersSuccess:^{
                [self.refreshButton.layer removeAllAnimations];
            } andFailure:^{
                [_pollTimeoutTimer invalidate];
                _pollTimeoutTimer = nil;
                [self.refreshButton.layer removeAllAnimations];
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Fitbit data could not be refreshed at this time. Please try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            [self.refreshButton.layer removeAllAnimations];
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
                [speedWeekly addObject:speedRhythm[i][@"speed_score"]];
            }

            
            self.fitbitSleepGraphView.data = sleepWeekly;
            self.fitbitActivityGraphView.data = stepsWeekly;
            self.fitbitBarGraphView.data = speedWeekly;
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
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"user: %@", [responseObject[@"data"] description]);
        [TPOAuthClient sharedClient].user = responseObject[@"data"];
        self.user = responseObject[@"data"];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 1) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Fail: %@", [error description]);
        [[TPOAuthClient sharedClient] handleError:error withOptionalMessage:@"Could not download results"];
        failureBlock();
    }];
}


-(void)setSleepChange:(float)sleepChange
{
    _sleepChange = sleepChange;
    self.sleepNumberLabel.text = [NSString stringWithFormat:@"%g",100*fabs(sleepChange)];
    if (sleepChange > 0) {
        self.sleepArrowImage.image = [UIImage imageNamed:@"fitbit-bluearrow-up.png"];
    } else if (sleepChange < 0) {
        self.sleepArrowImage.image = [UIImage imageNamed:@"fitbit-bluearrow-down.png"];
    } else if (!sleepChange) {
        self.sleepArrowImage.image = [UIImage imageNamed:@"fitbit-bluearrow.png"];
    }

}

-(void)setActivityChange:(float)activityChange
{
    _activityChange = activityChange;
    self.activityNumberLabel.text = [NSString stringWithFormat:@"%g%%",100*fabs(activityChange)];
    if (activityChange > 0) {
        self.activityArrowImage.image = [UIImage imageNamed:@"fitbit-yellowarrow-up.png"];
    } else if (activityChange < 0) {
        self.activityArrowImage.image = [UIImage imageNamed:@"fitbit-yellowarrow-down.png"];
    } else if (!activityChange) {
        self.activityArrowImage.image = [UIImage imageNamed:@"fitbit-yellowarrow.png"];
    }

}

-(void)setSpeedChange:(float)speedChange
{
    _speedChange = speedChange;
    self.speedNumberLabel.text = [NSString stringWithFormat:@"%g%%",100*fabs(speedChange)];
    if (speedChange > 0) {
        self.speedArrowImage.image = [UIImage imageNamed:@"fitbit-greenarrow-up.png"];
    } else if (speedChange < 0) {
        self.speedArrowImage.image = [UIImage imageNamed:@"fitbit-greenarrow-down.png"];
    } else if (!speedChange) {
        self.speedArrowImage.image = [UIImage imageNamed:@"fitbit-greenarrow.png"];
    }
}

@end
