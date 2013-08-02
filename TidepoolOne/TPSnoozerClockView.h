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

-(void)clockViewWasTouched:(TPSnoozerClockView *)clockView;

@end


@interface TPSnoozerClockView : UIView

@property (nonatomic, assign) BOOL isRinging;
@property id<TPSnoozerClockViewDelegate> delegate;

-(void)tappedCorrectly:(BOOL)correct;

@end
