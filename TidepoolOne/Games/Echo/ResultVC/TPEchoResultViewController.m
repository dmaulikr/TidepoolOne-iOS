//
//  TPEchoResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoResultViewController.h"

@interface TPEchoResultViewController ()
{
    NSDictionary *_result;
}
@end

@implementation TPEchoResultViewController

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

-(void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320, 630)];
}


-(void)setResult:(NSDictionary *)result
{
    _result = result;
    if (result) {
        self.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@.png", result[@"badge"][@"character"]]];
        self.badgeTitleLabel.text = result[@"badge"][@"title"];
        self.blurbView.text = result[@"badge"][@"description"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%@", result[@"attention_score"]];
        
        self.points_1.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][0][@"score"]];
        self.longestSequence_1.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][0][@"highest"]];
        
        self.points_2.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][1][@"score"]];
        self.longestSequence_2.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][1][@"highest"]];

    }
}

- (void)shareGame
{
#ifndef DEBUG
    //Analytics
    [[Mixpanel sharedInstance] track:@"Share" properties:@{@"item": @"Echo"}];
#endif
    NSString *message = [NSString stringWithFormat:@"I just scored %@ on Echo! Can you do better?", self.scoreLabel.text];
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
