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
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPSnoozerSummaryView" owner:nil options:nil];
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPSnoozerSummaryView class]]) {
            _snoozerSummaryView = item;
        }
    }
    [self addSubview:_snoozerSummaryView];
    
    nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPFitbitSummaryView" owner:nil options:nil];
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPFitbitSummaryView class]]) {
            _fitbitSummaryView = item;
        }
    }
    _fitbitSummaryView.frame = CGRectOffset(_fitbitSummaryView.frame, 0, _snoozerSummaryView.frame.size.height);
    [self addSubview:_fitbitSummaryView];
}
@end
