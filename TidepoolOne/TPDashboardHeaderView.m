//
//  TPDashboardHeaderView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardHeaderView.h"
#import "TPCircadianTooltipView.h"

@interface TPDashboardHeaderView()
{
    UIImageView *_legendView;
    TPCircadianTooltipView *_tooltipView;
}
@end

@implementation TPDashboardHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    UIImage *image = [UIImage imageNamed:@"dash-densityflag2.png"];
    _legendView = [[UIImageView alloc] initWithImage:image];
    _legendView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    _legendView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
    [self addGestureRecognizer:tap];

    
    _tooltipView = [[TPCircadianTooltipView alloc] initWithFrame:CGRectMake(0, 0, 85, 61)];
    _tooltipView.hidden = YES;
}

-(void)setDensityData:(NSArray *)densityData
{
    _densityData = densityData;
    UIImage *high = [UIImage imageNamed:@"dash-density-green.png"];
    UIImage *medium = [UIImage imageNamed:@"dash-density-yellow.png"];
    UIImage *low = [UIImage imageNamed:@"dash-density-red.png"];
    if (_densityData) {
        for (int i=0;i<_densityData.count;i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(i-0.5), 44, 66, 10)];
            int timesPlayed = [_densityData[i] intValue];
            if (timesPlayed <= 3) {
                imageView.image = low;
            } else if (timesPlayed <= 5) {
                imageView.image = medium;
            } else if (timesPlayed > 5) {
                imageView.image = high;
            }
            [self.scrollView addSubview:imageView];
        }
    }
}

-(void)viewWasTapped:(UIGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self.scrollView];

    if (!_legendView.hidden || !_tooltipView.hidden) {
        _legendView.hidden = YES;
        [_legendView removeFromSuperview];
        _tooltipView.hidden = YES;
        [_tooltipView removeFromSuperview];
    } else {
        if (touchPoint.y < 58) {
            _legendView.hidden = NO;
            _legendView.center = CGPointMake(touchPoint.x + _legendView.bounds.size.width/2, 49);
            [self.scrollView addSubview:_legendView];
        } else if (touchPoint.y > 60) {
            _tooltipView.hidden = NO;
            int index = [self indexForTouchPoint:touchPoint];
            float x = 32.5*index+22;
            if (index < 19) {
                x++;
            }
            _tooltipView.center = CGPointMake(x, 100);
            _tooltipView.score = self.results[index];
            [self.scrollView addSubview:_tooltipView];
        }
    }
}


-(int)indexForTouchPoint:(CGPoint)touchPoint
{
    float index = 24 * touchPoint.x / 790;
    return (int)index;
}


@end
