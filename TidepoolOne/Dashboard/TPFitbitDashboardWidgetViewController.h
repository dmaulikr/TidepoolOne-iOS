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

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UIView *connectView;
- (IBAction)connectAction:(id)sender;

@property (assign, nonatomic) BOOL isConnected;
@property (weak, nonatomic) IBOutlet UIScrollView *fitbitScrollView;
@property (weak, nonatomic) IBOutlet TPBarGraphView *fitbitBarGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitSleepGraphView;
@property (weak, nonatomic) IBOutlet TPCurveGraphView *fitbitActivityGraphView;


@property (assign, nonatomic) float speedChange;
@property (assign, nonatomic) float activityChange;
@property (assign, nonatomic) float sleepChange;


@property (weak, nonatomic) IBOutlet TPLabelBold *speedNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speedArrowImage;
@property (weak, nonatomic) IBOutlet TPLabelBold *activityNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityArrowImage;
@property (weak, nonatomic) IBOutlet TPLabelBold *sleepNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sleepArrowImage;

@property (strong, nonatomic) NSDictionary *user;

@end
