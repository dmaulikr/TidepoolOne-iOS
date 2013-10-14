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
    _moodChartView.positiveFraction = 0.5;
    _moodChartView.negativeFraction = 0.5;
    
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
    NSString *message = [NSString stringWithFormat:@"I just played FaceOff"];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tidepool/id691052387?mt=8"];
    
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
