//
//  TPSnoozerResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPResultViewController.h"
#import "TPSnoozerResultsGraphView.h"

@interface TPSnoozerResultViewController : TPResultViewController


@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) IBOutlet UILabel *currentFastestTime;
@property (nonatomic, strong) IBOutlet UILabel *blurbLabel;
@property (nonatomic, strong) NSArray *history;
@property (weak, nonatomic) IBOutlet TPLabel *animalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *animalBadgeImage;

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *playAgainButton;
@property (nonatomic, weak) IBOutlet UIButton *learnMoreButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet TPSnoozerResultsGraphView *gameLevelHistoryView;
@end
