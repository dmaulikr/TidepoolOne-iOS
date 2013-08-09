//
//  TPSnoozerClockView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPSnoozerClockView;

@protocol TPSnoozerClockViewDelegate

-(void)tappedClockView:(TPSnoozerClockView *)clockView correctly:(BOOL)correct;
-(void)showedPossibleClockInClockView:(TPSnoozerClockView *)clockView;

@end


@interface TPSnoozerClockView : UIView

@property (nonatomic, strong) NSArray *timeline;
@property (nonatomic, strong) NSArray *currentColorSequence;
@property (nonatomic, strong) NSArray *correctColorSequence;
@property (nonatomic, strong) NSString *currentColor;
@property (nonatomic, strong) NSString *correctColor;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, assign) BOOL isRinging;
@property id<TPSnoozerClockViewDelegate> delegate;

-(void)updatePicture;

@end
