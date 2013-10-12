//
//  TPCirclesDistanceView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/24/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPCirclesDistanceView.h"

@implementation TPCirclesDistanceView
{
    UIImageView *_imageView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate shouldAllowMoveCircle]) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:[self superview]];
//    if (!(currentPosition.x < 0.9*self.superview.bounds.size.width
//          && currentPosition.x > 0.1*self.superview.bounds.size.width
//          && currentPosition.y < 0.9*self.superview.bounds.size.height
//          )) {
//        return;
//    }
    [self.delegate moveCircle:self toPoint:currentPosition];
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
