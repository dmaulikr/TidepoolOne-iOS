//
//  TPEchoDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 11/14/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"
//#import "TPCurveGraphView.h"

@class TPCurveGraphView;

@interface TPEchoDashboardWidgetViewController : TPDashboardWidgetViewController

@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) NSArray *densityData;

@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet TPCurveGraphView *curveGraphView;
-(void)dismissPopovers;


@end
