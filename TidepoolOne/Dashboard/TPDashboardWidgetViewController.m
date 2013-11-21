//
//  TPDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"

@interface TPDashboardWidgetViewController ()
{
    NSDateFormatter *_hourFromDate;
    int _numServerCallsCompleted;
    BOOL _gettingMoreResults;
}
@end

@implementation TPDashboardWidgetViewController

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
	// Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getGameResultsForGameType:self.type limit:@10 offset:@0 WithCompletionHandlersSuccess:^(id dataObject) {
        self.results = [dataObject mutableCopy];
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [[TPOAuthClient sharedClient] forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:^(TPUser *user) {
        self.user = user;
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } andFailure:^{
        failureBlock();
    }];
}

-(void)reset
{
    //virtual function - no implementation
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

-(void)getMoreResults
{
    if (_gettingMoreResults) {
        return;
    }
    _gettingMoreResults = YES;
    [[TPOAuthClient sharedClient] getGameResultsForGameType:self.type limit:@10 offset:[NSNumber numberWithInt:self.results.count] WithCompletionHandlersSuccess:^(id dataObject) {
        NSArray *array = dataObject;
        if (array.count) {
            [self.results addObjectsFromArray:array];
            [self.tableView reloadData];
        }
        _gettingMoreResults = NO;
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
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
