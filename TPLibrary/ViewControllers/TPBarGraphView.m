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
    UIColor *_unselectedColor;
    UIColor *_selectedColor;
    int _tagOffset;
    UIView *_selectedView;
}
@end


@implementation TPBarGraphView

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
    [self setBackgroundColor:[UIColor clearColor]];
    _unselectedColor = [UIColor colorWithWhite:1.0 alpha:0.45];
    _selectedColor = [UIColor colorWithRed:37/255.0 green:144/255.0 blue:242/255.0 alpha:1.0];
    _tagOffset = 666; // the number of the beast!
}

- (void)drawRect:(CGRect)rect
{
    self.data = @[@100,@200,@30,@170,@60,@320];
    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
    float padding = 10;
    float barWidth = 20;
    float barMaxHeight = rect.size.height - 2 * padding;
    float barMinHeight = 20;
    float distanceBetweenBars = 10;
    
    float maxData = [[self.data valueForKeyPath:@"@max.floatValue"] floatValue];
    
    for (int i=0;i<_data.count;i++) {
        NSNumber *item = _data[i];
        float y = item.floatValue / maxData * barMaxHeight;
        float x = (barWidth + distanceBetweenBars) * i;
        CGRect barRect = CGRectMake(x, rect.size.height - padding, barWidth, -y);
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
