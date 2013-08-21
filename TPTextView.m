//
//  TPTextView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/20/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTextView.h"

@implementation TPTextView

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
    self.font = [UIFont fontWithName:@"Karla-Regular" size:self.font.pointSize];
    self.backgroundColor = [UIColor clearColor];
}

@end
