//
//  TPMoodChartView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/14/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPMoodChartView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *moodImageView;


@property (assign, nonatomic) float positiveFraction;
@property (assign, nonatomic) float negativeFraction;

@end
