//
//  TPEchoCircleView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoCircleView.h"
#import "CGHelper.h"

@implementation TPEchoCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [CGHelper strokeCircleAtPoint:CGPointMake(0, 0) withRadius:10 color:[UIColor blackColor]];
}

@end
