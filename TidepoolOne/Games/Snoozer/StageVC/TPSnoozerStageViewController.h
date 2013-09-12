//
//  TPSnoozerStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"
#import "TPSnoozerClockView.h"

@interface TPSnoozerStageViewController : TPStageViewController <TPSnoozerClockViewDelegate>

@property (assign) int numChoicesTotal;
@property (assign) int numChoices;
@property (assign) int numRows;
@property (assign) int numColumns;

@property (assign) NSTimeInterval maxTime;
@property (assign) NSTimeInterval minTime;

@property (assign) float timeToShow;

-(void)tappedClockView:(TPSnoozerClockView *)clockView correctly:(BOOL)correct;
-(void)showedRingingClockInClockView:(TPSnoozerClockView *)clockView;
-(void)instructionDone;

@end
