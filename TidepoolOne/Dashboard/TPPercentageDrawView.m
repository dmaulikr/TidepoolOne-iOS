//
//  TPPercentageDrawView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPercentageDrawView.h"
#import "CGHelper.h"

@interface TPPercentageDrawView()
{
    UIImageView *_posCircleImageView;
    UIImageView *_negCircleImageView
    ;
    UILabel *_posCircleLabel;
    UILabel *_negCircleLabel;
    
}
@end


@implementation TPPercentageDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setPositiveFraction:(float)positiveFraction
{
    _positiveFraction = positiveFraction;
    [self setNeedsDisplay];
}

-(void)setNegativeFraction:(float)negativeFraction
{
    _negativeFraction = negativeFraction;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 29.0);
    CGPoint center = CGPointMake(self.center.x, self.center.y + 11);
    float radius = 65;
    // Drawing code
    [CGHelper strokeArcAtPoint:center withRadius:radius startAngle:-M_PI endAngle:-(1-_positiveFraction)*M_PI color:[UIColor colorWithRed:251/255.0 green:187/255.0 blue:63/255.0 alpha:1.0]];
    [CGHelper strokeArcAtPoint:center withRadius:radius startAngle:(1-_negativeFraction)*M_PI endAngle:-M_PI color:[UIColor colorWithRed:91/255.0 green:207/255.0 blue:207/255.0 alpha:1.0]];
    UIImage *posCircleImage = [UIImage imageNamed:@"fo-pos-orangcircle.png"];
    UIImage *negCircleImage = [UIImage imageNamed:@"fo-neg-bluecircle.png"];
    
    UIFont *font = [UIFont fontWithName:@"Karla" size:13];
    if (!_posCircleImageView) {
        _posCircleImageView = [[UIImageView alloc] initWithImage:posCircleImage];
        [self addSubview:_posCircleImageView];
    }
    if (!_negCircleImageView) {
        _negCircleImageView = [[UIImageView alloc] initWithImage:negCircleImage];
        [self addSubview:_negCircleImageView];
    }
    if (!_posCircleLabel) {
        _posCircleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _posCircleLabel.font = font;
        _posCircleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_posCircleLabel];
    }
    if (!_negCircleLabel) {
        _negCircleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _negCircleLabel.font = font;
        _negCircleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_negCircleLabel];
    }
    
    float posTheta = M_PI * (_positiveFraction);
    float negTheta = -M_PI * (_negativeFraction);
    CGPoint posCenter = CGPointMake(center.x - radius*cosf(posTheta), center.y - radius*sinf(posTheta));
    CGPoint negCenter = CGPointMake(center.x - radius*cosf(negTheta), center.y - radius*sinf(negTheta));
    _posCircleImageView.center = _posCircleLabel.center = posCenter;
    _negCircleImageView.center = _negCircleLabel.center = negCenter;
    _posCircleLabel.text = [NSString stringWithFormat:@"%i%%", (int)(100*_positiveFraction)];
    _negCircleLabel.text = [NSString stringWithFormat:@"%i%%", (int)(100*_negativeFraction)];
}

@end
