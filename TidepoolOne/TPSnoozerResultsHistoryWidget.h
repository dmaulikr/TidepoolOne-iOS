//
//  TPSnoozerResultsHistoryWidget.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPSnoozerResultsHistoryWidget : UIView


@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *fastestTime;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastestTimeLabel;


@end
