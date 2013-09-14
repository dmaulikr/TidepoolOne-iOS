//
//  TPSnoozerDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"
#import "TPCurveGraphView.h"
#import "TPBarGraphView.h"

@interface TPSnoozerDashboardWidgetViewController : TPDashboardWidgetViewController

@property (strong, nonatomic) NSDictionary *user;
@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *curveGraphView;

@property (strong, nonatomic) NSArray *densityData;
@property (strong, nonatomic) NSArray *results;

-(void)dismissPopovers;

@end
