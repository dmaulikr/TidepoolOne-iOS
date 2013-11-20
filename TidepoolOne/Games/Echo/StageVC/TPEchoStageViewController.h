//
//  TPEchoStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"

@interface TPEchoStageViewController : TPStageViewController

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (assign, nonatomic) BOOL reverseMode;
@property (weak, nonatomic) IBOutlet UIView *numberContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *handImageView;
@property (weak, nonatomic) IBOutlet TPLabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIView *instructionContainerView;
@property (weak, nonatomic) IBOutlet UIView *circlesContainerView;

@end
