//
//  TPEIResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIResultViewController.h"
#import "TPEIGameViewController.h"
#import "TPMoodChartView.h"

@interface TPEIResultViewController ()
{
    NSDictionary *_result;
    TPMoodChartView *_moodChartView;
}
@end

@implementation TPEIResultViewController

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
    self.title = @"Results";
    //    [[TPLocalNotificationManager sharedInstance] createNotification];
    self.gameVC.navigationItem.rightBarButtonItem = nil;
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPMoodChartView" owner:nil options:nil];
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPMoodChartView class]]) {
             _moodChartView = item;
            [self.moodChartContainerView addSubview:_moodChartView];
        }
    }
    [self.blurbView setFont:[UIFont fontWithName:@"Karla" size:17.0]];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Google analytics tracker
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"FaceOff Result Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
    
}

-(void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320, 860)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setResult:(NSDictionary *)result
{
    _result = result;
    if (_result) {
        self.score = [_result[@"eq_score"] intValue];
        self.finishTimeLabel.text = [NSString stringWithFormat:@"%i",[_result[@"time_elapsed"] intValue] / 1000];
        self.instantReplaysLabel.text = _result[@"instant_replays"];
        self.correctLabel.text = _result[@"corrects"];
        self.incorrectLabel.text = _result[@"incorrects"];
        NSString *character = _result[@"badge"][@"character"];
        self.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@.png", character]];
        self.badgeTitle.text = _result[@"badge"][@"title"];
        [self.blurbView setText:_result[@"badge"][@"description"]];
        
        int positiveCorrect = 0;
        int positiveIncorrect = 0;
        int negativeCorrect = 0;
        int negativeIncorrect = 0;
        
        NSDictionary *emoGroups = _result[@"calculations"][@"emo_groups"];
        for (NSString *emo in emoGroups) {
            NSDictionary *stats = emoGroups[emo];
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
        self.moodLabel.text = [_result[@"reported_mood"] uppercaseString];
        self.positivePercentageLabel.text = [NSString stringWithFormat:@"%i", (int)(100*positiveFraction)];
        self.negativePercentageLabel.text = [NSString stringWithFormat:@"%i", (int)(100*negativeFraction)];
        
        _moodChartView.moodImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"howfeeling-%@-pressed.png", _result[@"reported_mood"]]];
        _moodChartView.positiveFraction = positiveFraction;
        _moodChartView.negativeFraction = negativeFraction;
        
    }
}

-(void)setScore:(int)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", score];
}



-(NSDictionary *)result
{
    return _result;
}

- (IBAction)shareGame
{
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Share" properties:@{@"item": @"FaceOff"}];
#endif
    NSString *message = [NSString stringWithFormat:@"I just played FaceOff and I'm %@, scoring %i! Can you do better?", self.badgeTitle.text, self.score];
    NSURL *url = [NSURL URLWithString:APP_LINK];
    
    NSArray *postItems = @[message, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
    } else {
        // Load resources for iOS 7 or later
        [activityVC setExcludedActivityTypes:@[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact]];
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
