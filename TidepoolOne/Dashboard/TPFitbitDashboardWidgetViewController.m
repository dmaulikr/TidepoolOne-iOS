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

-(void)downloadResultswithCompletionHandlersSuccess:(void (^)())successBlock andFailure:(void (^)())failureBlock
{
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/sleeps" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
        NSLog(@"sucess:%i",[(NSArray *)responseObject[@"data"] count]);
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 3) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
        failureBlock();
    }];
    
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/activities" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
        NSLog(@"sucess:%i",[(NSArray *)responseObject[@"data"] count]);
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 3) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
        failureBlock();
    }];
    
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?daily=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess:%@",[responseObject description]);
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 3) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"errorRRRR: %@", error);
        failureBlock();
    }];
    
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
@end
