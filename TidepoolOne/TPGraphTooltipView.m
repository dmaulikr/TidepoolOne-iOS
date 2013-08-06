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
        // Initialization code
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImage];
        backgroundImage.image = [UIImage imageNamed:@"historychart-bubble.png"
                                 ];
        CGRect bubbleFrame = frame;
        bubbleFrame.size.height *= 0.8;
        self.scoreLabel = [[TPLabel alloc] initWithFrame:CGRectMake(0, 0, bubbleFrame.size.width/2, bubbleFrame.size.height)];
        self.dateLabel = [[TPLabel alloc] initWithFrame:CGRectMake(bubbleFrame.size.width/2, 0, bubbleFrame.size.width/2, bubbleFrame.size.height/2)];
        self.timeLabel = [[TPLabel alloc] initWithFrame:CGRectMake(bubbleFrame.size.width/2, bubbleFrame.size.height/2, bubbleFrame.size.width/2, bubbleFrame.size.height/2)];
        
        self.scoreLabel.textColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        
        self.scoreLabel.fontSize = 20;
        self.dateLabel.fontSize = 10;
        self.timeLabel.fontSize = 10;

        self.scoreLabel.centered = YES;        
        
        [self addSubview:self.scoreLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.timeLabel];
    }
    return self;
}

-(void)setPointingAtView:(UIView *)pointingAtView
{
    _pointingAtView = pointingAtView;
    CGPoint point = pointingAtView.center;
    point.y -= (pointingAtView.bounds.size.height + self.bounds.size.height)/2.0;
    self.center = point;
}

-(void)setDate:(NSDate *)date
{
    _date = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.timeLabel.text = [dateFormatter stringFromDate:date];
}

-(void)setScore:(NSString *)score
{
    _score = score;
    self.scoreLabel.text = score;
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
