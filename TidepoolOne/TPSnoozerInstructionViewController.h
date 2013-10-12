//
//  TPSnoozerInstructionViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPSnoozerClockView;
@class TPSnoozerStageViewController;

@interface TPSnoozerInstructionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *levelNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionsDetailLabel;
@property (weak, nonatomic) TPSnoozerStageViewController *stageVC;
@property (weak, nonatomic) IBOutlet TPSnoozerClockView *clockViewLeft;
@property (weak, nonatomic) IBOutlet TPSnoozerClockView *clockViewRight;
@end
