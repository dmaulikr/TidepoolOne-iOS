//
//  TPFaceoffDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/11/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPDashboardWidgetViewController.h"

@interface TPFaceoffDashboardWidgetViewController : TPDashboardWidgetViewController

@property (strong, nonatomic) NSDictionary *user;
@property (weak, nonatomic) IBOutlet TPLabelBold *dailyBestLabel;
@property (weak, nonatomic) IBOutlet TPLabelBold *allTimeBestLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSDictionary *emoGroupFractions;
@property (strong, nonatomic) NSArray *results;

@end
