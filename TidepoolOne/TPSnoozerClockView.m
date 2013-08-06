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
    NSTimeInterval _ringingTimeInterval;
    NSMutableDictionary *_imageDictionary;
    CGSize _baseSize;
    CGPoint relativeCenter;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isRinging = NO;
        _ringingState = 0;
        _imageDictionary = [NSMutableDictionary dictionary];

        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock.png"] forKey:@"static"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring1.png"] forKey:@"ring1"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring2.png"] forKey:@"ring2"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock-correct.png"] forKey:@"correct"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-missed.png"] forKey:@"incorrect"];
        _ringingTimeInterval = 0.2;
        
        UIImage *image = _imageDictionary[@"static"];
        _baseSize = image.size;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _baseSize.width, _baseSize.width)];
        relativeCenter.x = self.bounds.size.width/2;
        relativeCenter.y = self.bounds.size.height/2;
        _imageView.center = relativeCenter;
        [self addSubview:_imageView];
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
//    _imageView.transform = CGAffineTransformMakeRotation(0);
    _imageView.image = _imageDictionary[@"static"];
    [UIView animateWithDuration:0.4 animations:^{
        _imageView.frame = CGRectMake(0,0 ,_baseSize.width, _baseSize.height);
        _imageView.center = relativeCenter;
    }];
}

-(void)drawRingingClock
{
    NSArray *keyArray = @[@"static",@"ring1",@"ring2"];
    _ringingState =  ((_ringingState + 1) % 3);
    _imageView.image = _imageDictionary[keyArray[_ringingState]];
    float factor = 1.0;
    [UIView animateWithDuration:0.4 animations:^{
        _imageView.frame = CGRectMake(0,0 ,factor*_baseSize.width, factor*_baseSize.height);
        _imageView.center = relativeCenter;
    }];
    if ( _ringingState - 1 ) {
//        _imageView.transform = CGAffineTransformMakeRotation(M_PI + 0.5 * M_PI_4 * ((rand()%3) - 2) - 3);
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
        _imageView.image = _imageDictionary[@"correct"];
    } else {
        _imageView.image = _imageDictionary[@"incorrect"];
    }
//    _imageView.transform = CGAffineTransformMakeRotation(0);
    [UIView animateWithDuration:0.4 animations:^{
        _imageView.frame = CGRectMake(0,0 ,_baseSize.width, _baseSize.height);
        _imageView.center = relativeCenter;
    }];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(drawStaticClock) userInfo:nil repeats:NO];
}


@end
