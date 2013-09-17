//
//  TPFitbitDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFitbitDashboardWidgetViewController.h"
#import "TPServiceLoginViewController.h"

@interface TPFitbitDashboardWidgetViewController ()
{
    int _numServerCallsCompleted;
    CGSize _connectedSize;
    CGSize _notConnectedSize;
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
    self.fitbitActivityGraphView.data = @[@13, @52, @23, @44, @15, @26, @71];
    self.fitbitSleepGraphView.data = @[@13, @52, @23, @44, @15, @126, @71];
    self.fitbitBarGraphView.unselectedColor = [UIColor colorWithRed:63/255.0 green:201/255.0 blue:167/255.0 alpha:1.0];
    self.fitbitActivityGraphView.color = [UIColor colorWithRed:250/255.0 green:187/255.0 blue:61/255.0 alpha:1.0];
    self.fitbitSleepGraphView.color = [UIColor colorWithRed:2/255.0 green:110/255.0 blue:160/255.0 alpha:1.0];
    _connectedSize = self.view.bounds.size;
    _notConnectedSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - self.fitbitScrollView.frame.size.height);
    self.isConnected = NO;
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
        self.headerImageView.image = [UIImage imageNamed:@"dash-fitbitbg-connect.png"];
        self.connectButton.hidden = NO;
    } else {
        self.headerImageView.image = [UIImage imageNamed:@"dash-fitbitbg.png"];
        self.view.bounds = CGRectMake(0, 0, _connectedSize.width, _connectedSize.height);
        self.connectButton.hidden = YES;
    }
}

-(void)showConnectUI
{
    TPServiceLoginViewController *serviceVC = [[TPServiceLoginViewController alloc] init];
    serviceVC.view.frame = self.view.bounds;
    [self.navigationController pushViewController:serviceVC animated:YES];
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
    // TODO: refresh API fitbit
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?daily=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshButton.layer removeAllAnimations];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshButton.layer removeAllAnimations];
    }];

}

-(void)setUser:(NSDictionary *)user
{
    _user = user;
    if (_user) {
//        NSArray *aggregateResults = _user[@"aggregate_results"];
//        if (aggregateResults.count && (aggregateResults != (NSArray *)[NSNull null])) {
//            NSArray *stepsRhythm = aggregateResults[1][@"scores"][@"weekly"];
//            NSMutableArray *stepsWeekly = [NSMutableArray array];
//            for (int i=0; i < stepsRhythm.count; i++) {
//                [stepsWeekly addObject:stepsRhythm[i][@"average_steps"]];
//            }
//            NSArray *sleepRhythm = aggregateResults[2][@"scores"][@"weekly"];
//            NSMutableArray *sleepWeekly = [NSMutableArray array];
//            for (int i=0; i < sleepRhythm.count; i++) {
//                [sleepWeekly addObject:sleepRhythm[i][@"average_minutes"]];
//            }
//            self.fitbitSleepGraphView.data = sleepWeekly;
//            self.fitbitActivityGraphView.data = stepsWeekly;
//        }
    }
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


@end
