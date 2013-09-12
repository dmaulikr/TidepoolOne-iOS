//
//  TPPolarChartView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPPolarChartView.h"
#import "CGHelper.h"

@implementation TPPolarChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.colors = @[[UIColor colorWithRed:60/255.0 green:188/255.0 blue:175/255.0 alpha:1.0],[UIColor colorWithRed:115/255.0 green:115/255.0 blue:115/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:175/255.0 blue:48/255.0 alpha:1.0],[UIColor colorWithRed:233/255.0 green:98/255.0 blue:103/255.0 alpha:1.0],[UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0],];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.colors = @[[UIColor colorWithRed:60/255.0 green:188/255.0 blue:175/255.0 alpha:1.0],[UIColor colorWithRed:115/255.0 green:115/255.0 blue:115/255.0 alpha:1.0],[UIColor colorWithRed:255/255.0 green:175/255.0 blue:48/255.0 alpha:1.0],[UIColor colorWithRed:233/255.0 green:98/255.0 blue:103/255.0 alpha:1.0],[UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0],];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float angle = 2*M_PI / self.data.count;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2);
    float maxValue = [[self.data valueForKeyPath:@"@max.floatValue"] floatValue];
    float radius = 0.8 * self.bounds.size.width/2;
    for (int i=0;i<self.data.count;i++) {
        [CGHelper fillSliceAtPoint:center withRadius:[self.data[i] floatValue]*radius/maxValue startAngle:(i+0.5)*angle endAngle:(i+1.5)*angle color:self.colors[i]];
        [CGHelper strokeSliceAtPoint:center withRadius:[self.data[i] floatValue]*radius/maxValue startAngle:(i+0.5)*angle endAngle:(i+1.5)*angle color:[UIColor whiteColor]];
    }
}

-(void)setData:(NSArray *)data
{
    _data = data;
    [self setNeedsDisplay];
}

@end
