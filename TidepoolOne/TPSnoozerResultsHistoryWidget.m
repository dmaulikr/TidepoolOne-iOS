//
//  TPSnoozerResultsHistoryWidget.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultsHistoryWidget.h"

@implementation TPSnoozerResultsHistoryWidget

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDate:(NSDate *)date
{
    _date = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.timeLabel.text = [dateFormatter stringFromDate:date];
    self.fastestTimeLabel.text = @"270";
}

-(void)setFastestTime:(NSNumber *)fastestTime
{
    _fastestTime = fastestTime;
    self.fastestTimeLabel.text = [NSString stringWithFormat:@"%@", _fastestTime];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
