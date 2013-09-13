//
//  TPFitbitSummaryView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/12/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPBarGraphView.h"
#import "TPCurveGraphView.h"

@interface TPFitbitSummaryView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *fitbitScrollView;
@property (weak, nonatomic) IBOutlet TPBarGraphView *fitbitBarGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitSleepGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitActivityGraphView;

@end
