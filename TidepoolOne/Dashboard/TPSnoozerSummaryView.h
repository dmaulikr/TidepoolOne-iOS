//
//  TPSnoozerSummaryView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/12/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPBarGraphView.h"
#import "TPCurveGraphView.h"

@interface TPSnoozerSummaryView : UIView

@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *curveGraphView;

@property (strong, nonatomic) NSArray *densityData;
@property (strong, nonatomic) NSArray *results;

@end
