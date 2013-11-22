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
    TPUser *_user;
}
@end

@implementation TPFaceoffDashboardWidgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.type = @"EmoIntelligenceResult";
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
    _emotions = @[@"happy",@"sad",@"angry",@"surprised",@"disgusted",@"afraid",@"neutral"];
    
    self.user = self.user;
    [self setTextForEmotion:@"happy"];
}



-(void)viewWillAppear:(BOOL)animated
{
    // TODO : This shouldn't need to be here...
    [super viewWillAppear:animated];
    self.view.bounds = CGRectMake(0, 0, 320, 395);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUser:(TPUser *)user
{
    _user = user;
    if (_user) {
        @try {
            NSArray *aggregateResults = _user.aggregateResults;
            if (aggregateResults.count) {
                NSDictionary *emoAggregateResult = [_user aggregateResultOfType:@"EmoAggregateResult"];
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

-(TPUser *)user
{
    return _user;
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
    if (indexPath.row > self.results.count - 3) {
        [self getMoreResults];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _emotions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *emotion = _emotions[indexPath.row];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"howfeeling-%@-pressed.png", emotion]];
    float imageSize = image.size.width * 0.6;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((cell.bounds.size.width - imageSize)/2, (cell.bounds.size.height - imageSize)/2, imageSize, imageSize)];
    imageView.image = image;
    // TODO: efficiency
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview:imageView];
//    imageView.center = cell.center;
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
    int page = 2*(self.collectionView.contentOffset.x / self.collectionView.frame.size.width);
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
            [emo isEqualToString:@"disgusted"] ||
            [emo isEqualToString:@"afraid"] ||
            [emo isEqualToString:@"sad"] ||
            [emo isEqualToString:@"shocked"]) {
            negativeCorrect += [stats[@"corrects"] intValue];
            negativeIncorrect += [stats[@"incorrects"] intValue];
        } else {
            positiveCorrect += [stats[@"corrects"] intValue];
            positiveIncorrect += [stats[@"incorrects"] intValue];
        }
    }
    
    float positiveFraction = (float)positiveCorrect/(positiveCorrect+positiveIncorrect);
    float negativeFraction = (float)negativeCorrect/(negativeCorrect+negativeIncorrect);
    if (positiveFraction == positiveFraction && positiveCorrect > 0) {
        self.percentageDrawView.positiveFraction = positiveFraction;
        self.positivePercentage.text = [NSString stringWithFormat:@"%i", (int)(100*(float)positiveFraction)];
    } else {
        self.percentageDrawView.positiveFraction = 0.001;
        self.positivePercentage.text = @"0";
    }
    if (negativeFraction == negativeFraction && negativeCorrect > 0) {
        self.percentageDrawView.negativeFraction = negativeFraction;
        self.negativePercentage.text = [NSString stringWithFormat:@"%i", (int)(100*(float)negativeFraction)];
        
    } else {
        self.percentageDrawView.negativeFraction = 0.001;
        self.negativePercentage.text = @"0";
    }
}


@end