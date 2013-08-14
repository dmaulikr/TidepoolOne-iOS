//
//  TPSnoozerResultsHistoryWidget.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerResultsHistoryWidget.h"

@interface TPSnoozerResultsHistoryWidget()
{
    BOOL _pageControlUsed;
}
@end
@implementation TPSnoozerResultsHistoryWidget

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
}

-(void)awakeFromNib
{
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*2, 109);
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
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

- (IBAction)changePage:(id)sender {
    _pageControlUsed = YES;
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!_pageControlUsed)
        _pageControl.currentPage = lround(_scrollView.contentOffset.x /
                                          (_scrollView.contentSize.width / _pageControl.numberOfPages));
}
@end
