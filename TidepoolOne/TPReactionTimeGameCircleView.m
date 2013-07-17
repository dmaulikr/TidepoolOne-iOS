//
//  TPReactionTimeGameCircleView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeGameCircleView.h"
#import "CGHelper.h"

#define REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER 4

@interface TPReactionTimeGameCircleView()
{
    CAShapeLayer *circleLayer;
    CAShapeLayer *concentricCircleLayer[REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER];
    NSTimer *colorChangeTimer;
    NSDictionary *_colors;
    BOOL colorChangeTimerActive;
    UIColor *previousColor;
    int stage;
    int sequenceNo;
}
@end

@implementation TPReactionTimeGameCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        colorChangeTimerActive = YES;
        stage = 0;
        sequenceNo = 0;
        _colors = @{@"red":[UIColor redColor],
                   @"green":[UIColor greenColor],
                   @"yellow":[UIColor yellowColor],
                   };
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    circleLayer = [CAShapeLayer layer];
    CGMutablePathRef path = [CGHelper newCirclePathAtPoint:self.center withRadius:60];
    circleLayer.path = path;
    CGPathRelease(path);
    circleLayer.fillColor = [UIColor redColor].CGColor;

    for (int i=0;i<REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER;i++) {
        concentricCircleLayer[i] = [CAShapeLayer layer];
        concentricCircleLayer[i].path = circleLayer.path;
        concentricCircleLayer[i].fillColor = CGColorCreateCopyWithAlpha([UIColor redColor].CGColor, 1-0.2*i);
        [self.layer addSublayer:concentricCircleLayer[i]];
    }
    [self.layer addSublayer:circleLayer];
    [self nextCircleColor];
}

-(void)circleTouched
{
    switch (stage) {
        case 0:{
            if (circleLayer.fillColor != [_colors[@"red"] CGColor])
                return;
        }
            break;
        case 1:{
//            if (circleLayer.fillColor != colors[0].CGColor || previousColor.CGColor != colors[1].CGColor)
                return;
        }
            break;
        default:
            break;
    }
    colorChangeTimerActive = NO;
    for (int i=0;i<REACTION_TIME_GAME_CONCENTRIC_CIRCLE_NUMBER;i++) {
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        growAnimation.fromValue = (__bridge id)(concentricCircleLayer[i].path);
        growAnimation.toValue = (__bridge id)([CGHelper newCirclePathAtPoint:self.center withRadius:60 + 15*i]);
        growAnimation.duration = 0.25;
        growAnimation.autoreverses = YES;
        [concentricCircleLayer[i] addAnimation:growAnimation forKey:@"path"];
    }
    colorChangeTimerActive = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        if (CGPathContainsPoint(circleLayer.path, nil, touchPoint, NO)) {
            [self circleTouched];
        }
    }
}

-(void)nextCircleColor
{
    if (colorChangeTimerActive) {
        previousColor = [UIColor colorWithCGColor:circleLayer.fillColor];
        circleLayer.fillColor = [_colors[self.sequence[sequenceNo][@"color"]] CGColor];
        colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:[self.sequence[sequenceNo][@"interval"] floatValue]*0.001 target:self selector:@selector(nextCircleColor) userInfo:nil repeats:NO];
        sequenceNo++;
    }
}

@end