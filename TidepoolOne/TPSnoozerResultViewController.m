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
    BOOL _firstTimeHackFix;
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
    _firstTimeHackFix = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"results-bg.png"]];
    //hack
    if (!_firstTimeHackFix) {
        _firstTimeHackFix = YES;
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                /*Do iPhone 5 stuff here.*/
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+20);
            } else {
                /*Do iPhone Classic stuff here.*/
            }
        } else {
            /*Do iPad stuff here.*/
        }
    }
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
        self.currentFastestTime.text = result[@"average_time"];
        self.blurbLabel.text = [result[@"bullet_description"] componentsJoinedByString:@" "];
        self.animalLabel.text = [result[@"speed_archetype"] uppercaseString];
        self.animalBadgeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@",result[@"speed_archetype"]]];
        NSMutableArray *historyMutable = [result[@"calculations"][@"stage_data"] mutableCopy];
        for (int i=0;i<historyMutable.count;i++){
            historyMutable[i] = historyMutable[i][@"average_time"];
        }
        self.history = historyMutable;
        self.gameLevelHistoryView.results = self.history;
    }
}

-(NSDictionary *)result
{
    return _result;
}
@end
