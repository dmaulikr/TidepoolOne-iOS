//
//  TPSnoozerResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultViewController.h"
#import "TPLocalNotificationManager.h"

@interface TPSnoozerResultViewController ()
{
    NSDictionary *_result;
}
@end

@implementation TPSnoozerResultViewController

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
    self.history = @[@220, @270, @230, @250];
    self.gameLevelHistoryView.results = self.history;
    [[TPLocalNotificationManager sharedInstance] createNotification];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Snoozer Result Screen"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"results-bg.png"]];
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
        self.currentFastestTime.text = result[@"speed_score"];
        self.blurbLabel.text = result[@"description"];
        self.animalLabel.text = [result[@"speed_archetype"] uppercaseString];
        if ([self.animalLabel.text hasPrefix:@"PROGRESS"]) {
            self.animalLabel.text = @"";
            self.messageLabel.text = @"";
        }
        self.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@",result[@"speed_archetype"]]];
        NSMutableArray *historyMutable = [result[@"calculations"][@"stage_data"] mutableCopy];
        for (int i=0;i<historyMutable.count;i++){
            historyMutable[i] = historyMutable[i][@"score"];
        }
        self.history = historyMutable;
        self.gameLevelHistoryView.results = self.history;
    }
}

-(NSDictionary *)result
{
    return _result;
}
- (IBAction)shareAction:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"I just scored %@ on Snoozer! Can you do better?", self.currentFastestTime.text];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tidepool/id691052387?mt=8"];
    
    NSArray *postItems = @[message, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
    
    
@end
