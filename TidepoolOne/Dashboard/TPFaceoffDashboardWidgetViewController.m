//
//  TPFaceoffDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/11/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFaceoffDashboardWidgetViewController.h"
#import "TPSnoozerResultCell.h"

@interface TPFaceoffDashboardWidgetViewController ()
{
    NSDateFormatter *_hourFromDate;
    int _numServerCallsCompleted;
    UIImageView *_legendView;
}
@end

@implementation TPFaceoffDashboardWidgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hourFromDate = [[NSDateFormatter alloc] init];
        [_hourFromDate setDateFormat:@"HH"];
        UIImage *image = [UIImage imageNamed:@"dash-densityflag2.png"];
        _legendView = [[UIImageView alloc] initWithImage:image];
        _legendView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        _legendView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        [self.view addGestureRecognizer:tap];
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=EmoIntelligenceResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    [[TPOAuthClient sharedClient] forceRefreshOfUserInfoFromServerWithCompletionHandlersSuccess:^(NSDictionary *user) {
        self.user = user;
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } andFailure:^{
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
                NSDictionary *emoAggregateResult = [self getAggregateScoreOfType:@"EmoAggregateResult" fromArray:aggregateResults];
                self.allTimeBestLabel.text = emoAggregateResult[@"high_scores"][@"all_time_best"];
                self.dailyBestLabel.text = emoAggregateResult[@"high_scores"][@"daily_best"];
                self.emoGroupFractions = emoAggregateResult[@"scores"];
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
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TPDashboardTableCell";
    //    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
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
    cell.fastestTime = self.results[indexPath.row][@"eq_score"];
    cell.animalLabel.text = [self.results[indexPath.row][@"speed_archetype"] uppercaseString];
//    if ([cell.animalLabel.text hasPrefix:@"PROGRESS"]) {
//        cell.animalLabel.text = @"";
//    }
    
//    cell.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"anim-badge-%@.png", self.results[indexPath.row][@"speed_archetype"]]];
//    cell.detailLabel.text = self.results[indexPath.row][@"description"];
    [cell adjustScrollView];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}



@end