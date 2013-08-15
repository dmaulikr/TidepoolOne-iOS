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
        // Initialization code
        self.bold = YES;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.bold = YES;
    }
    return self;
}

@end
