//
//  TPBarGraphView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPBarGraphView : UIView

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) UIColor *unselectedColor;

@property (assign, nonatomic) float barWidth;
@property (assign, nonatomic) float distanceBetweenBars;
@property (assign, nonatomic) float firstOffset;
@property (assign, nonatomic) float topBottomPadding;

@end
