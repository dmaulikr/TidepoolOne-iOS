//
//  TPSnoozerResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPResultViewController.h"
#import "TPLabel.h"

@interface TPSnoozerResultViewController : TPResultViewController

@property (nonatomic, strong) IBOutlet UILabel *currentFastestTime;
@property (nonatomic, strong) IBOutlet UILabel *numberCorrect;
@property (nonatomic, strong) IBOutlet UILabel *numberWrong;
@property (nonatomic, strong) NSArray *history;

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *playAgainButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIView *bottomBar;
@end
