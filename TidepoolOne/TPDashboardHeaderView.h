//
//  TPDashboardHeaderView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPBarGraphView.h"

@interface TPDashboardHeaderView : UIView

@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet TPBarGraphView *barGraphView;

@end
