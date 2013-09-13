//
//  TPDashboardHeaderView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPSnoozerSummaryView.h"
#import "TPFitbitSummaryView.h"

@interface TPDashboardHeaderView : UIView

@property (strong, nonatomic) TPSnoozerSummaryView *snoozerSummaryView;
@property (strong, nonatomic) TPFitbitSummaryView *fitbitSummaryView;

@end
