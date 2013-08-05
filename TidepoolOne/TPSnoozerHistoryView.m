//
//  TPSnoozerHistoryView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/4/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerHistoryView.h"

@implementation TPSnoozerHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        UIImage *image = [UIImage imageNamed:@"snoozer-clock.png"];
        for (int i=0;i<self.dataPoints.count;i++) {
            
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
