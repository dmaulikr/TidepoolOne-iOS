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

@property (nonatomic, strong) NSNumber *currentFastestTime;
@property (nonatomic, strong) NSNumber *numberCorrect;
@property (nonatomic, strong) NSNumber *numberWrong;
@property (nonatomic, strong) NSArray *history;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *rightButton;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *playAgainButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;


@end
