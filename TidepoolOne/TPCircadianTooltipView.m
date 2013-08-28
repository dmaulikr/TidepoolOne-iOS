//
//  TPCircadianTooltipView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/28/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPCircadianTooltipView.h"

@implementation TPCircadianTooltipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImage];
        backgroundImage.image = [UIImage imageNamed:@"dash-chartflag-flip.png"];
        CGRect bubbleFrame = frame;
        bubbleFrame.size.height *= 0.8;
        self.scoreLabel = [[TPLabelBold alloc] initWithFrame:CGRectMake(0, 0*bubbleFrame.size.height, bubbleFrame.size.width, 0.8*bubbleFrame.size.height)];
        self.scoreLabel.textColor = [UIColor whiteColor];
        self.scoreLabel.fontSize = 20;
        self.scoreLabel.centered = YES;
        [self addSubview:self.scoreLabel];
        
        TPLabel *pointsLabel = [[TPLabelBold alloc] initWithFrame:CGRectMake(0, 0.7*bubbleFrame.size.height, bubbleFrame.size.width, 0.2*bubbleFrame.size.height)];
        pointsLabel.textColor = [UIColor whiteColor];
        pointsLabel.text = @"POINTS";
        pointsLabel.fontSize = 10;
        pointsLabel.centered = YES;
        [self addSubview:pointsLabel];

        
    }
    return self;
}

-(void)setScore:(NSString *)score
{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%@", score];
}

@end