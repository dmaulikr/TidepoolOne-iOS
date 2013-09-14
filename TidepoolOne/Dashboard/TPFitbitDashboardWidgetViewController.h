//
//  TPFitbitDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"
#import "TPCurveGraphView.h"
#import "TPBarGraphView.h"

@interface TPFitbitDashboardWidgetViewController : TPDashboardWidgetViewController

@property (weak, nonatomic) IBOutlet UIScrollView *fitbitScrollView;
@property (weak, nonatomic) IBOutlet TPBarGraphView *fitbitBarGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitSleepGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitActivityGraphView;

@end
