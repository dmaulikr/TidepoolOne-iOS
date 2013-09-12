//
//  TPGraphTooltipView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/5/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGraphTooltipView.h"


@implementation TPGraphTooltipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:backgroundImage];
    backgroundImage.image = [UIImage imageNamed:@"historychart-bubble2.png"
                             ];
    CGRect bubbleFrame = self.bounds;
    bubbleFrame.size.height *= 0.8;
    self.levelLabel = [[TPLabelBold alloc] initWithFrame:CGRectMake(0, 4, bubbleFrame.size.width, 0.3*bubbleFrame.size.height)];
    self.scoreLabel = [[TPLabelBold alloc] initWithFrame:CGRectMake(0, 0.2*bubbleFrame.size.height, bubbleFrame.size.width, 0.8*bubbleFrame.size.height)];
    
    self.levelLabel.textColor = [UIColor colorWithRed:248/255.0 green:186/255.0 blue:60/255.0 alpha:1.0];
    self.scoreLabel.textColor = [UIColor whiteColor];
    
    self.levelLabel.fontSize = 10;
    self.scoreLabel.fontSize = 22;
    
    self.levelLabel.centered = YES;
    self.scoreLabel.centered = YES;
    
    self.levelLabel.text = @"Level 4";
    
    [self addSubview:self.scoreLabel];
    [self addSubview:self.levelLabel];
}

-(void)setPointingAtView:(UIView *)pointingAtView
{
    _pointingAtView = pointingAtView;
    CGPoint point = pointingAtView.center;
    point.y -= 0.7*(pointingAtView.bounds.size.height + self.bounds.size.height);
    self.center = point;
}

//-(void)setDate:(NSDate *)date
//{
//    _date = date;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM/dd/yy"];
//    self.dateLabel.text = [dateFormatter stringFromDate:date];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    self.timeLabel.text = [dateFormatter stringFromDate:date];
//}

-(void)setScore:(NSString *)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%@", score];
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
