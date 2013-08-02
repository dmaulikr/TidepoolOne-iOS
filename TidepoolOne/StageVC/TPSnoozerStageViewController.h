//
//  TPSnoozerStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"

@interface TPSnoozerStageViewController : TPStageViewController

@property (assign) int numChoices;
@property (assign) int numRows;
@property (assign) int numColumns;
@property (assign) NSTimeInterval maxTime;
@property (assign) NSTimeInterval minTime;

@end
