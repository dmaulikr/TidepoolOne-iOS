//
//  TPSnoozerSurveyStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"

@interface TPSnoozerSurveyStageViewController : TPStageViewController
@property (weak, nonatomic) IBOutlet UILabel *sleepQuestion;
@property (weak, nonatomic) IBOutlet UISlider *sleepSlider;
@property (weak, nonatomic) IBOutlet UILabel *activityQuestion;
@property (weak, nonatomic) IBOutlet UISlider *activitySlider;

- (IBAction)submitStage:(id)sender;
- (IBAction)sleepMoved:(id)sender;
- (IBAction)activityMoved:(id)sender;
@end
