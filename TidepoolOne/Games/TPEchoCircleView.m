//
//  TPEchoCircleView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoCircleView.h"
#import "CGHelper.h"
#import <AVFoundation/AVFoundation.h>

#define NUM_GHOST_CIRCLES 3

@interface TPEchoCircleView()
{
    CAShapeLayer *circleLayer;
    CAShapeLayer *ghostLayers[NUM_GHOST_CIRCLES];
    CGPoint _center;
}
@end

@implementation TPEchoCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _color = [UIColor colorWithRed:64/255.0 green:191/255.0 blue:239/255.0 alpha:1];
        _radius = 30;
        _strokeWidth = 5;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    _center = CGPointMake(rect.size.width/2, rect.size.height/2);
    // Drawing code
    if (!circleLayer ) {
        circleLayer = [CAShapeLayer layer];
        [self.layer addSublayer:circleLayer];
        circleLayer.path = [CGHelper newCirclePathAtPoint:_center withRadius:_radius];
        circleLayer.lineWidth = _strokeWidth;
        circleLayer.fillColor = [[UIColor clearColor] CGColor];
        circleLayer.strokeColor = [_color CGColor];
    }
    if (!ghostLayers[0]) {
        for (int i=0;i<NUM_GHOST_CIRCLES;i++) {
            ghostLayers[i] = [CAShapeLayer layer];
            ghostLayers[i].path = [CGHelper newCirclePathAtPoint:_center withRadius:_radius];
            ghostLayers[i].fillColor = [[UIColor clearColor] CGColor];
            ghostLayers[i].lineWidth = _strokeWidth;
            float alpha = (1 - (i+1.0)/(NUM_GHOST_CIRCLES+1.0));
            ghostLayers[i].strokeColor = [[self color:_color WithAlpha:alpha] CGColor];

            [self.layer addSublayer:ghostLayers[i]];
        }
    }
}

-(UIColor *)color:(UIColor *)color WithAlpha:(float)alpha
{
    CGFloat r,g,b,a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    }
    return nil;
}

-(void)setFilled:(BOOL)filled
{
    _filled = filled;
    if (filled) {
        circleLayer.fillColor = [_color CGColor];
    } else {
        circleLayer.fillColor = [[UIColor clearColor] CGColor];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.filled = YES;
    NSLog(@"it's now set to yes");
    [self.delegate tappedCircle:self];
}

-(void)animateRipple
{
    float radius = 30;
    float strokeWidth = 5;
    [CATransaction begin]; {
    for (int i=0;i<NUM_GHOST_CIRCLES;i++) {
            [CATransaction setCompletionBlock:^{
                self.filled = NO;
                NSLog(@"it's now set to no");
            }];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
            animation.duration = 0.5;
            animation.fromValue = (id)[CGHelper newCirclePathAtPoint:_center withRadius:radius+((i)*strokeWidth)];
            animation.toValue = (id)[CGHelper newCirclePathAtPoint:_center withRadius:radius+((i + 2)*strokeWidth)];
            animation.autoreverses = NO;
            [ghostLayers[i] addAnimation:animation forKey:@"path"];
        }
    } [CATransaction commit];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.filled) {
        [self animateRipple];
    }
}

-(void)play
{
    self.filled = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setNotFilled) userInfo:nil repeats:NO];
    [self playSoundCorrect:YES];
}

-(void)playSoundCorrect:(BOOL)correct
{
    NSString *filename;
    if (correct) {
        filename = [NSString stringWithFormat:@"%@", _pitch];
    } else {
        filename = [NSString stringWithFormat:@"%@e", _pitch];
    }
    NSString *pewPewPath = [[NSBundle mainBundle]
                            pathForResource:filename ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    SystemSoundID _pewPewSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
    AudioServicesPlaySystemSound(_pewPewSound);
}

-(void)setNotFilled
{
    self.filled = NO;
}

@end
