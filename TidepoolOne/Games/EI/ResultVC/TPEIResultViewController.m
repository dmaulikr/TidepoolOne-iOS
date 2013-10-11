//
//  TPEIResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIResultViewController.h"
#import "TPEIGameViewController.h"

@interface TPEIResultViewController ()
{
    NSDictionary *_result;
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
        self.badgeImageView = nil;
        self.blurbView = nil;
        // TODO : debug - remove when server calculates
//        self.score = [_result[@"eq_score"] intValue];
        self.score = self.gameVC.gameScore;
        self.finishTimeLabel.text = [NSString stringWithFormat:@"%i",[_result[@"time_elapsed"] intValue] / 1000];
        self.instantReplaysLabel.text = _result[@"instant_replays"];
        self.correctLabel.text = _result[@"corrects"];
        self.incorrectLabel.text = _result[@"incorrects"];
    }
}

-(void)setScore:(int)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", score];
    NSString *character;
    if (score < 1000) {
        character = @"sheldon";
    } else if (score < 2000) {
        character = @"abe";
    } else if (score < 3000) {
        character = @"walt";
    } else if (score < 4000) {
        character = @"einstein";
    } else {
        character = @"oprah";
    }
    self.badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 265)];
    [self.topView insertSubview:self.badgeImageView atIndex:0];
    self.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@.png", character]];
    NSDictionary *characterNames = @{
                                     @"sheldon":@"Know It All.. Not",
                                     @"abe":@"Honest Abe",
                                     @"walt":@"Imagineer",
                                     @"einstein":@"Genius",
                                     @"oprah":@"Talk Show Diva",
                                     };
    self.badgeTitle.text = characterNames[character];
    
    NSDictionary *characterBlurbs = @{
                                      @"sheldon":@"If you ever thought intellectual ability was all you needed to succeed, you are for a \"Big Bang\". Emotional intelligence is the ability to be aware of your own emotions, cope with change, understand the needs of others and maintain positive relationships with people.",
                                      @"abe":@"Your ability to regulate your own emotions is key for your extraordinary levels of humility. Humility does not come easy to any leader, and you might achieve more due to your unique levels of EQ.",
                                      @"walt":@"A person with such high emotional intelligence can be very pragmatic because of your skills to understand people around you. You can use this to steer groups for forming new ideas and inspiring to achieve dreams.",
                                      @"einstein":@"You are good at combining your intelligence with understanding people around you. This unique combination will help you excel at work and in your relationships.",
                                      @"oprah":@"You are powerful in the sense that lot of people look to you in times of need. Not only will you guide people with your intelligent advice but you can also express empathy very well. Your strength in emotional intelligence makes you a authentic leader in your field.",
                                      };
    
    self.blurbView = [[UITextView alloc] initWithFrame:CGRectMake(10, 85, 188, 173)];
    self.blurbView.backgroundColor = [UIColor clearColor];
    [self.blurbView setFont:[UIFont fontWithName:@"Karla" size:17]];
    [self.topView addSubview:self.blurbView];
    [self.blurbView setText:characterBlurbs[character]];
}



-(NSDictionary *)result
{
    return _result;
}

- (IBAction)shareGame
{
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
