//
//  TPFaceoffDashboardWidgetViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/11/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPFaceoffDashboardWidgetViewController.h"
#import "TPSnoozerResultCell.h"

@interface TPFaceoffDashboardWidgetViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>
{
    int _numServerCallsCompleted;
    NSArray *_emotions;
}
@end

@implementation TPFaceoffDashboardWidgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    _emotions = @[@"happy",@"sad",@"fear",@"surprised",@"disgust",@"surprised"];
    
    self.user=self.user;
    [self setTextForEmotion:@"happy"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    self.allTimeBestLabel.text = @"";
    self.dailyBestLabel.text = @"";
    self.percentageDrawView.positiveFraction = 0.001;
    self.percentageDrawView.negativeFraction = 0.001;
    self.results = nil;
    self.emotionLabel.text = @"";
    self.positivePercentage.text = @"";;
    self.negativePercentage.text = @"";

    
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
    cell.animalLabel.text = [self.results[indexPath.row][@"badge"][@"title"] uppercaseString];
    cell.detailLabel.text = self.results[indexPath.row][@"badge"][@"description"];
//    if ([cell.animalLabel.text hasPrefix:@"PROGRESS"]) {
//        cell.animalLabel.text = @"";
//    }
    
    cell.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"celeb-badge-%@.png", self.results[indexPath.row][@"badge"][@"character"]]];

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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _emotions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *emotion = _emotions[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"howfeeling-%@-pressed.png", emotion]]];
    imageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    // TODO: efficiency
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview:imageView];
    return cell;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self getCurrentPage];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self getCurrentPage];
    }
}

-(void)getCurrentPage
{
    int page = (self.collectionView.contentOffset.x / self.collectionView.frame.size.width + 0.5);
    NSString *emotion = _emotions[page];
    [self setTextForEmotion:emotion];
}

-(void)setTextForEmotion:(NSString *)emotion
{
    self.emotionLabel.text = [emotion uppercaseString];
    NSDictionary *currentEmoGroupFraction = _emoGroupFractions[emotion];
    int positiveCorrect = 0;
    int positiveIncorrect = 0;
    int negativeCorrect = 0;
    int negativeIncorrect = 0;
    
    for (NSString *emo in currentEmoGroupFraction) {
        NSDictionary *stats = currentEmoGroupFraction[emo];
        if ([emo isEqualToString:@"angry"] ||
            [emo isEqualToString:@"disgust"] ||
            [emo isEqualToString:@"fear"] ||
            [emo isEqualToString:@"sad"] ||
            [emo isEqualToString:@"shock"]) {
            negativeCorrect += [stats[@"corrects"] intValue];
            negativeIncorrect += [stats[@"incorrects"] intValue];
        } else {
            positiveCorrect += [stats[@"corrects"] intValue];
            positiveIncorrect += [stats[@"incorrects"] intValue];
        }
    }
    
    float positiveFraction = (float)positiveCorrect/(positiveCorrect+positiveIncorrect);
    float negativeFraction = (float)negativeCorrect/(negativeCorrect+negativeIncorrect);
    self.positivePercentage.text = [NSString stringWithFormat:@"%i", (int)(100*(float)positiveFraction)];
    self.negativePercentage.text = [NSString stringWithFormat:@"%i", (int)(100*(float)negativeFraction)];
    if (positiveFraction == positiveFraction) {
        self.percentageDrawView.positiveFraction = positiveFraction;
    } else {
        self.percentageDrawView.positiveFraction = 0.001;
    }
    if (negativeFraction == negativeFraction) {
        self.percentageDrawView.negativeFraction = negativeFraction;
    } else {
        self.percentageDrawView.negativeFraction = 0.001;
    }
}


@end