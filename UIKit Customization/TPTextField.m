//
//  TPTextField.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation TPTextField

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.font = [UIFont fontWithName:@"Karla-Regular" size:20.0];
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}


- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor lightGrayColor] setFill];
    rect.origin.y = rect.origin.y + ((rect.size.height - self.font.pointSize) / 2);
    [[self placeholder] drawInRect:rect withFont:self.font];
}

@end
