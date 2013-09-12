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
}

- (void)drawRect:(CGRect)rect
{
    self.data = @[@1,@2,@3,@4,@5,@6,@7];
    _distanceBetweenBars = 77.5;
    _firstOffset = 45;
    _selectedColor = [UIColor colorWithRed:215/255.0 green:57/255.0 blue:57/255.0 alpha:1.0];
    _unselectedColor = [UIColor colorWithRed:215/255.0 green:57/255.0 blue:57/255.0 alpha:1.0];
    _barWidth = 20;
    _topBottomPadding = 0;
    
    float barMaxHeight = rect.size.height - 2 * _topBottomPadding;

    float maxData = [[self.data valueForKeyPath:@"@max.floatValue"] floatValue];
    
    for (int i=0;i<_data.count;i++) {
        NSNumber *item = _data[i];
        float y = item.floatValue / maxData * barMaxHeight;
        float x = _firstOffset + (_barWidth + _distanceBetweenBars) * i;
        CGRect barRect = CGRectMake(x, rect.size.height - _topBottomPadding, _barWidth, -y);
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





@end
