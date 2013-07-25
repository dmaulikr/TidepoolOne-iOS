//
//  TPCustomScrollView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/24/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPCustomScrollView.h"

@implementation TPCustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
