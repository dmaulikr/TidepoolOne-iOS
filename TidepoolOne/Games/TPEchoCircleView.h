//
//  TPEchoCircleView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPEchoCircleView;

@protocol TPEchoCircleViewDelegate <NSObject>

-(void)tappedCircle:(TPEchoCircleView *)circle;

@end

@interface TPEchoCircleView : UIView

@property (assign, nonatomic) BOOL filled;

@property (assign, nonatomic) BOOL radius;
@property (assign, nonatomic) BOOL strokeWidth;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSNumber *pitch;
@property (weak, nonatomic) id delegate;


-(void)play;
-(void)playSoundCorrect:(BOOL)correct;
@end
