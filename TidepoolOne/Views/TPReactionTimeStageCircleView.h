//
//  TPReactionTimeStageCircleView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TPReactionTimeStageCircleViewDelegateProtocol

-(void)circleViewWasTapped;

@end

@interface TPReactionTimeStageCircleView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, weak) id<TPReactionTimeStageCircleViewDelegateProtocol> delegate;
@property float radius;
@property float animationDuration;

-(void)animateCirclePress;

@end
