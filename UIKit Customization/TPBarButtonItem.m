//
//  TPBarButtonItem.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/14/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPBarButtonItem.h"

@implementation TPBarButtonItem

-(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    self = [super initWithTitle:title style:style target:target action:action];
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
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        [self setBackgroundImage:[UIImage imageNamed:@"btn-rect2.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    } else {
        //Default in iOS 7 is cool
    }
    NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : [UIFont fontWithName:@"Karla-Regular" size:13.0],UITextAttributeTextColor : [UIColor blackColor],UITextAttributeTextShadowOffset : @0,
                                              };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    [self setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
}


@end
