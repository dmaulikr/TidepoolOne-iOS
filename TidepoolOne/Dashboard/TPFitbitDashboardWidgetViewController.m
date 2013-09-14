//
//  TPFitbitDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFitbitDashboardWidgetViewController.h"

@interface TPFitbitDashboardWidgetViewController ()
{
    int _numServerCallsCompleted;
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
    self.fitbitSleepGraphView.color = [UIColor redColor];
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

@end
