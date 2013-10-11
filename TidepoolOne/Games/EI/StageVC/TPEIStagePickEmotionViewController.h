//
//  TPEIStagePickEmotionViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPStageViewController.h"

@interface TPEIStagePickEmotionViewController : TPStageViewController


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *drawerView;

@property (weak, nonatomic) IBOutlet UIButton *emo_4_0;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_1;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_2;
@property (weak, nonatomic) IBOutlet UIButton *emo_4_3;
@property (weak, nonatomic) IBOutlet TPLabel *instructionsLabel;


@property (weak, nonatomic) IBOutlet TPLabel *scoreLabel;
@property (assign, nonatomic) int score;


@property (assign, nonatomic) int imageIndex;
@property (strong, nonatomic) NSArray *imagesData;
@property (assign, nonatomic) float timeToShow;

@property (strong, nonatomic) NSString *primary;
@property (strong, nonatomic) NSString *secondary;
@property (strong, nonatomic) NSString *primaryNuanced;
@property (assign, nonatomic) int instantReplayCount;
@property (assign, nonatomic) BOOL isSecondary;
@property (assign, nonatomic) BOOL isNuanced;
@property (assign, nonatomic) BOOL lastAnswerCorrect;
@property (assign, nonatomic) BOOL imageIsHidden;
@property (assign, nonatomic) BOOL imageHasSecondaryEmotion;
@property (assign, nonatomic) BOOL imageHasNuancedEmotion;
//scoring
@property (assign, nonatomic) int correctBaseScore;
@property (assign, nonatomic) int incorrectBaseScore;
@property (assign, nonatomic) int instantReplayBaseScore;
@property (assign, nonatomic) float primaryMultiplier;
@property (assign, nonatomic) float secondaryMultiplier;
@property (assign, nonatomic) float difficultyMultiplier;

- (IBAction)emotionChosen:(id)sender;

@end
