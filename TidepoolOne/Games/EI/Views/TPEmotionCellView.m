//
//  TPEmotionCellView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEmotionCellView.h"

@interface TPEmotionCellView()
{
    UIImageView *_imgView;
    UILabel *_label;
}
@end

@implementation TPEmotionCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        float imageSize = 96;
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - imageSize)/2, (frame.size.height - imageSize)/2 - 20, imageSize, imageSize)];
        [self addSubview:_imgView];
        _label = [[TPLabelBold alloc] initWithFrame:CGRectMake(0, (frame.size.height - imageSize)/2 - 0 + imageSize, frame.size.width, 22)];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setEmotion:(NSString *)emotion selected:(BOOL)selected
{
    _label.text = [emotion uppercaseString];
    _label.textColor = selected ? [UIColor colorWithRed:24/155.0 green:143/255.0 blue:244/255.0 alpha:1.0] : [UIColor colorWithWhite:0.55 alpha:1.0];
    NSString *onOrOff = selected ? @"-pressed" : @"";
    _imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"howfeeling-%@%@.png", emotion, onOrOff]];
}

@end
