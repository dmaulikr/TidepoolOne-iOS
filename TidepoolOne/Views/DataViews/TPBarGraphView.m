//
//  TPBarGraphView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPBarGraphView.h"

@interface TPBarGraphView()
{
    int _tagOffset;
    UIView *_selectedView;
}
@end


@implementation TPBarGraphView

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
    [self setBackgroundColor:[UIColor clearColor]];
    _unselectedColor = [UIColor colorWithWhite:1.0 alpha:0.45];
    _selectedColor = [UIColor colorWithRed:37/255.0 green:144/255.0 blue:242/255.0 alpha:1.0];
    _tagOffset = 666; // the number of the beast!
    _distanceBetweenBars = 97.5;
    _firstOffset = 42;
    _barWidth = 30;
    _topBottomPadding = 0;
}

- (void)drawRect:(CGRect)rect
{
    if (!_data) {
        return;
    }
    float barMaxHeight = rect.size.height - 2 * _topBottomPadding;

    float maxData = [[self.data valueForKeyPath:@"@max.floatValue"] floatValue];
    
    for (int i=0;i<_data.count;i++) {
        NSNumber *item = _data[i];
        float y = item.floatValue / maxData * barMaxHeight;
        float x = _firstOffset + (_distanceBetweenBars) * i + 0.5*_barWidth;
        CGRect barRect = CGRectMake(x - _barWidth/2, rect.size.height - _topBottomPadding, _barWidth, -y);
        UIView *barView = [[UIView alloc] initWithFrame:barRect];
        barView.backgroundColor = _unselectedColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barWasTapped:)];
        barView.tag = _tagOffset + i;
        [barView addGestureRecognizer:tap];
        [self addSubview:barView];
    }
}

-(void)barWasTapped:(UIGestureRecognizer *)sender
{
    UIView *tappedView = sender.view;
    if (tappedView == _selectedView) {
        tappedView.backgroundColor = _unselectedColor;
        _selectedView = nil;
    } else {
        _selectedView.backgroundColor = _unselectedColor;
        tappedView.backgroundColor = _selectedColor;
        _selectedView = tappedView;
    }
}

-(void)setData:(NSArray *)data
{
    _data = data;
    [self setNeedsDisplay];
}



@end
