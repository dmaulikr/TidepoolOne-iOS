//
//  TPFaceoffDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/11/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"
#import "TPPercentageDrawView.h"

@interface TPFaceoffDashboardWidgetViewController : TPDashboardWidgetViewController

@property (weak, nonatomic) IBOutlet TPPercentageDrawView *percentageDrawView;
@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet TPLabelBold *emotionLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *positivePercentage;
@property (weak, nonatomic) IBOutlet TPLabelBold *negativePercentage;

@property (strong, nonatomic) NSDictionary *emoGroupFractions;

@end
