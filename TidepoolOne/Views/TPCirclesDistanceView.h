//
//  TPCirclesDistanceView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/24/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TPCirclesDistanceView;


@protocol TPCirclesDistanceViewDelegate

-(bool)shouldAllowMoveCircle;
-(void)moveCircle:(TPCirclesDistanceView *)circle toPoint:(CGPoint)point;

@end


@interface TPCirclesDistanceView : UIView

@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) id<TPCirclesDistanceViewDelegate> delegate;

@property (nonatomic) CGPoint acceleration;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint position;

@property (nonatomic) float radius;

@end
