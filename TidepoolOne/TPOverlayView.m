//
//  TPOverlayView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPOverlayView.h"

@interface TPOverlayView()
{
    void (^_completionBlock)(void);
}
@end

@implementation TPOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAndPerformCompletionBlock)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

-(void)dismissAndPerformCompletionBlock
{
    [self removeFromSuperview];
    _completionBlock();
}

-(void)setCompletionBlock:(void (^)(void))completionBlock
{
    _completionBlock = completionBlock;
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
