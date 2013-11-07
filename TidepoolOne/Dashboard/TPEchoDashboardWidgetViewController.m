//
//  TPEchoDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoDashboardWidgetViewController.h"
#import "TPSnoozerResultCell.h"

@interface TPEchoDashboardWidgetViewController ()
{
    int _numServerCallsCompleted;
}
@end

@implementation TPEchoDashboardWidgetViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
{
    _numServerCallsCompleted = 0;
    [[TPOAuthClient sharedClient] getPath:@"api/v1/users/-/results?type=AttentionResult"parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.results = responseObject[@"data"];
        self.results = [[self.results reverseObjectEnumerator] allObjects];
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
//        self.user = user;
        _numServerCallsCompleted++;
        if (_numServerCallsCompleted == 2) {
            successBlock();
        }
    } andFailure:^{
        failureBlock();
    }];
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
    cell.animalLabel.text = [self.results[indexPath.row][@"badge"][@"character"] uppercaseString];
    if ([cell.animalLabel.text hasPrefix:@"PROGRESS"]) {
        cell.animalLabel.text = @"";
    }
    
    cell.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"celeb-badge-%@.png", self.results[indexPath.row][@"badge"][@"character"]]];
    cell.detailLabel.text = self.results[indexPath.row][@"badge"][@"description"];
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
