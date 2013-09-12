//
//  TPDashboardHeaderView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPBarGraphView.h"
#import "TPCurveGraphView.h"

@interface TPDashboardHeaderView : UIView

@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet TPBarGraphView *barGraphView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *curveGraphView;

@property (strong, nonatomic) NSArray *densityData;
@property (strong, nonatomic) NSArray *results;


@property (weak, nonatomic) IBOutlet UIScrollView *fitbitScrollView;
@property (weak, nonatomic) IBOutlet TPBarGraphView *fitbitBarGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitSleepGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitActivityGraphView;

-(void)dismissPopovers;

@end
