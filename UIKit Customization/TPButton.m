//
//  TPButton.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/15/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPButton.h"

@implementation TPButton

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

-(id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

+(id)buttonWithType:(UIButtonType)buttonType
{
    TPButton *button = [super buttonWithType:buttonType];
    if (button) {
        [button commonInit];
    }
    return button;
}

-(void)commonInit
{
    self.titleLabel.font = [UIFont fontWithName:@"Karla-Bold" size:15.0];
}


@end
