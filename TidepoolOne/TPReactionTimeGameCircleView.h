//
//  TPReactionTimeGameCircleView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TPReactionTimeGameCircleViewDelegateProtocol

-(void)circleViewWasTapped;

@end

@interface TPReactionTimeGameCircleView : UIView

@property (nonatomic, strong) UIColor *color;
@property float radius;
@property (nonatomic, weak) id<TPReactionTimeGameCircleViewDelegateProtocol> delegate;
-(void)animateCirclePress;
@end
