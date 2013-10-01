//
//  TPEIResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEIResultViewController.h"

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
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"FaceOff Result Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];
    
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
        self.finishTimeLabel.text = [NSString stringWithFormat:@"%i",[_result[@"time_elapsed"] intValue] / 1000];
        self.instantReplaysLabel.text = _result[@"instant_replays"];
        self.correctLabel.text = _result[@"corrects"];
        self.incorrectLabel.text = _result[@"incorrects"];

    }
}

-(NSDictionary *)result
{
    return _result;
}

- (IBAction)shareAction:(id)sender
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
