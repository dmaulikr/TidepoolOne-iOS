//
//  TPSnoozerClockView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerClockView.h"

@implementation TPSnoozerClockView
{
    UIImageView *_imageView;
    int _ringingState;
    NSTimer *_ringingTimer;
    NSArray *_staticClockImages;
    NSArray *_ringingClockImages;
    NSString *_correctClockImage;
    NSString *_incorrectClockImage;
    NSTimeInterval _ringingTimeInterval;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        self.isRinging = NO;
        _ringingState = 0;
        _staticClockImages = @[@"snoozer-clock.png"];
        _ringingClockImages = @[@"snoozer-clock.png", @"snoozer-clockring1.png", @"snoozer-clockring2.png"];
        _correctClockImage = @"snoozer-clock-correct.png";
        _incorrectClockImage = @"snoozer-clock-missed.png";
        _ringingTimeInterval = 0.2;

    }
    return self;
}

-(void)setIsRinging:(BOOL)isRinging
{
    _isRinging = isRinging;
    if (_isRinging) {
        _ringingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(drawRingingClock) userInfo:nil repeats:YES];
        [self drawRingingClock];
    } else {
        [_ringingTimer invalidate];
        _ringingTimer = nil;
        [self drawStaticClock];
    }
}

-(void)drawStaticClock
{
    _imageView.transform = CGAffineTransformMakeRotation(0);    
    _imageView.image = [UIImage imageNamed:_staticClockImages[0]];
}

-(void)drawRingingClock
{
    _ringingState =  (_ringingState + 1) % _ringingClockImages.count;
    _imageView.image = [UIImage imageNamed:_ringingClockImages[_ringingState]];
    if (_ringingState) {
        _imageView.transform = CGAffineTransformMakeRotation(M_PI + 0.5 * M_PI_4 * ((rand()%3) - 2) - 3);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL correct = _isRinging;
    [self tappedCorrectly:correct];
    [self.delegate clockView:self  wasTouchedCorrectly:correct];
}

-(void)tappedCorrectly:(BOOL)correct
{
    self.isRinging = NO;
    if (correct) {
        _imageView.transform = CGAffineTransformMakeRotation(0);
        _imageView.image = [UIImage imageNamed:_correctClockImage];
    } else {
        _imageView.transform = CGAffineTransformMakeRotation(0);        
        _imageView.image = [UIImage imageNamed:_incorrectClockImage];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(drawStaticClock) userInfo:nil repeats:NO];
}

@end
