//
//  TPCurveGraphView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/27/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPCurveGraphView.h"

@implementation TPCurveGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    _color = [UIColor colorWithRed:36/255.0 green:145/255.0 blue:241/255.0 alpha:1.0];    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    float distBetweenPoints = rect.size.width / _data.count;
    float yMin = [[self.data valueForKeyPath:@"@min.floatValue"] floatValue];
    float yMax = [[self.data valueForKeyPath:@"@max.floatValue"] floatValue];
    if (!yMin && !yMax) {
        return;
    }
    float yRange = yMax - yMin;
    float yScale = 0.8*rect.size.height / yRange;
    
    for (int i=0;i<_data.count;i++) {
        float x = (i+0.5)*distBetweenPoints;
        float y = rect.size.height - (yScale * [_data[i] floatValue] - yMin);
        if (i==0) {
            CGPathMoveToPoint(path, NULL, x, y);
        } else {
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetLineWidth(context, 10);
    CGContextStrokePath(context);
    CGPathRelease(path);
}

-(void)setData:(NSArray *)data
{
    _data = data;
    [self setNeedsDisplay];
}

@end
