//
//  TPEIResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPResultViewController.h"

@interface TPEIResultViewController : TPResultViewController

@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, assign) int score;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet TPLabelBold *badgeTitle;
@property (strong, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (strong, nonatomic) IBOutlet TPTextView *blurbView;
@property (weak, nonatomic) IBOutlet TPLabel *finishTimeLabel;
@property (weak, nonatomic) IBOutlet TPLabel *instantReplaysLabel;
@property (weak, nonatomic) IBOutlet TPLabel *correctLabel;
@property (weak, nonatomic) IBOutlet TPLabel *incorrectLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *moodChartContainerView;

@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
