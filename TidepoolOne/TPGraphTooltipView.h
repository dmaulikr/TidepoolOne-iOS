//
//  TPGraphTooltipView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLabel.h"

@interface TPGraphTooltipView : UIView

@property (nonatomic, weak) NSDate *date;
@property (nonatomic, weak) NSString *score;
@property (nonatomic, weak) UIView *pointingAtView;

@property (nonatomic, strong) TPLabel *scoreLabel;
@property (nonatomic, strong) TPLabel *dateLabel;
@property (nonatomic, strong) TPLabel *timeLabel;

@end