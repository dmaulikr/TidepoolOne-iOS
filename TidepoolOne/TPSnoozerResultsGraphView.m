//
//  TPSnoozerResultsGraphView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultsGraphView.h"

@implementation TPSnoozerResultsGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    self.contentSize = CGSizeMake(1000, rect.size.height);
    self.results = @[@234,@354,@654,@345,];
    self.backgroundColor = [UIColor redColor];
    UIImage *image = [UIImage imageNamed:@"snoozer-clock.png"];
    int imageSideSize = 30;
    int distanceBetweenClocks = rect.size.width / self.results.count;
    float yStartScreen = 0.2*rect.size.height;
    float yRangeScreen = 0.6*rect.size.height;
    float minValue = [[_results valueForKeyPath:@"@min.intValue"] floatValue];
    float maxValue = [[_results valueForKeyPath:@"@max.intValue"] floatValue];
    float yRangeResults = maxValue - minValue;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    int numDashes = 2;
    CGFloat *dashPatternArray = malloc(numDashes*sizeof(CGFloat));
    dashPatternArray[0] = 10;    //drawn line
    dashPatternArray[1] = 7;    //empty space
    
    // Drawing code
    for (int i=0;i<self.results.count;i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        if (i+1 == self.results.count) {
            imageSideSize *= 2;
        }
        imageView.frame = CGRectMake(0, 0, imageSideSize, imageSideSize);
        float x = (i+0.35)*distanceBetweenClocks;
        float y = yStartScreen + ([_results[i] floatValue] - minValue) / yRangeResults * yRangeScreen;
        //add path between clocks
        if (i==0) {
            CGPathMoveToPoint(path, nil, x, y);
        } else {
            CGPathAddLineToPoint(path, nil, x, y);
        }
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:108/255.0 green:187/255.0 blue:168/255.0 alpha:1] CGColor]);
        CGContextAddPath(context, path);
        CGContextSetLineWidth(context, 5.0);
        CGContextStrokePath(context);
        //add horizontal lines
        CGMutablePathRef linePath = CGPathCreateMutable();
        CGPathMoveToPoint(linePath,nil, x, yStartScreen);
        CGPathAddLineToPoint(linePath, nil, x, yStartScreen + yRangeScreen);
        //create stupid array
        CGPathRef dashLinePath;
        dashLinePath = CGPathCreateCopyByDashingPath(linePath, nil, 0, dashPatternArray, numDashes);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:145/255.0 green:150/255.0 blue:150/255.0 alpha:1.0].CGColor);
        CGContextAddPath(context, dashLinePath);
        CGContextStrokePath(context);
        CGPathRelease(linePath);
        CGPathRelease(dashLinePath);
        //add clocks
        imageView.center = CGPointMake(x, y);
        [self addSubview:imageView];
    }
    free(dashPatternArray);
    CGPathRelease(path);
}


@end
