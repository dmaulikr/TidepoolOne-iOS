//
//  TPLabelBold.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/14/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLabelBold.h"

@implementation TPLabelBold

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.bold = YES;
}

@end
