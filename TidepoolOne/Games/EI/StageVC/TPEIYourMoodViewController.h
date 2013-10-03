//
//  TPEIYourMoodViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"

@interface TPEIYourMoodViewController : TPStageViewController


@property (strong, nonatomic) NSArray *emotions;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) int selectedEmotionIndex;

@end
