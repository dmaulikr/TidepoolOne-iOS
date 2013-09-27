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
@property (weak, nonatomic) IBOutlet UIButton *emo_1;
@property (weak, nonatomic) IBOutlet UIButton *emo_2;
@property (weak, nonatomic) IBOutlet UIButton *emo_3;


@property (assign, nonatomic) int imageIndex;
@property (strong, nonatomic) NSArray *imagesData;
@property (assign, nonatomic) float timeToShow;

@property (strong, nonatomic) NSString *primary;
@property (strong, nonatomic) NSString *secondary;
@property (assign, nonatomic) int instantReplayCount;
@property (assign, nonatomic) BOOL isSecondary;

@end
