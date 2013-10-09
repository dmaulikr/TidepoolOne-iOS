//
//  TPSnoozerResultCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/9/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPSnoozerResultCell : UITableViewCell

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *fastestTime;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *fastestTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *animalLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *animalBadgeImage;

- (IBAction)changePage:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailLabel;


-(void)adjustScrollView;

@end
