//
//  TPSnoozerClockView.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/2/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerClockView.h"
#import <AudioToolbox/AudioServices.h>

@implementation TPSnoozerClockView
{
    UIImageView *_imageView;
    int _ringingState;
    NSTimer *_resetToStaticTimer;
    NSTimeInterval _ringingTimeInterval;
    NSMutableDictionary *_imageDictionary;
    CGSize _baseSize;
    CGPoint relativeCenter;
    BOOL _showingResponseImage;
    BOOL _response;
    int _shownCounter;
    float _staticScale;
    float _ringingScale;
    
    NSMutableArray *_timerArray;
    NSMutableArray *_timerDatesArray;
    
    NSDate *_pauseTime;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitIvars];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInitIvars];
    }
    return self;
}

-(void)commonInitIvars
{
    self.backgroundColor = [UIColor clearColor];
    _timerArray = [NSMutableArray array];
    _timerDatesArray = [NSMutableArray array];
    self.isRinging = NO;
    self.currentColor = @"green";
    _ringingState = 0;
    _shownCounter = 0;
    _staticScale = 0.75;
    _ringingScale = 1.5;
    _imageDictionary = [NSMutableDictionary dictionary];
    
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock.png"] forKey:@"green"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring1.png"] forKey:@"green-ringing-1"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring2.png"] forKey:@"green-ringing-2"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock-correct.png"] forKey:@"correct"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock-missed.png"] forKey:@"incorrect"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockb.png"] forKey:@"orange"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringb1.png"] forKey:@"orange-ringing-1"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringb2.png"] forKey:@"orange-ringing-2"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockc.png"] forKey:@"yellow"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringc1.png"] forKey:@"yellow-ringing-1"];
    [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringc2.png"] forKey:@"yellow-ringing-2"];
    
    
    _timeToShow = 2000;
    UIImage *image = _imageDictionary[@"green"];
    _baseSize = image.size;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _baseSize.width, _baseSize.width)];
    relativeCenter.x = self.bounds.size.width/2;
    relativeCenter.y = self.bounds.size.height/2;
    _imageView.center = relativeCenter;
    [self addSubview:_imageView];
    _imageView.transform = CGAffineTransformMakeScale(_staticScale, _staticScale);
    _imageView.animationDuration = 0.25;
    [self updatePicture];
}


-(void)updatePicture
{
    if (_showingResponseImage) {
        [_imageView stopAnimating];
        if (_response) {
            _imageView.image = _imageDictionary[@"correct"];
        } else {
            _imageView.image = _imageDictionary[@"incorrect"];
        }
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.transform = CGAffineTransformMakeScale(_staticScale, _staticScale);
            ;
        }];
        _showingResponseImage = NO;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setStaticClockFromTimer:) userInfo:@"green" repeats:NO];
        [_timerArray addObject:timer];
        [_timerDatesArray addObject:timer.fireDate];
    } else {
        if (_isRinging) {
            NSArray *animationImages = @[_imageDictionary[_currentColor],_imageDictionary[[NSString stringWithFormat:@"%@-ringing-1",_currentColor]],_imageDictionary[[NSString stringWithFormat:@"%@-ringing-2",_currentColor]]];
            _imageView.animationImages = animationImages;
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _imageView.transform = CGAffineTransformMakeScale(_ringingScale, _ringingScale);
            } completion:^(BOOL finished) {
            }];
            [_imageView startAnimating];
        } else {
            [_imageView stopAnimating];
            _imageView.image = _imageDictionary[_currentColor];
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _imageView.transform = CGAffineTransformMakeScale(_staticScale, _staticScale);
            } completion:^(BOOL finished) {
            }];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_resetToStaticTimer invalidate];
    _resetToStaticTimer = nil;
    _response = [self isTarget];
    if (!_response) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    [self.delegate tappedClockView:self correctly:_response];
    _showingResponseImage = YES;
    self.isRinging = NO;
    [self updatePicture];
}

-(BOOL)isTarget
{
    return _isRinging && ([_currentColor isEqualToString:_correctColor]) && ([_currentColorSequence isEqualToArray:_correctColorSequence]);
}

-(void)setTimeline:(NSArray *)timeline
{
    _timeline = timeline;
    
    for (int i=0;i<timeline.count;i++) {
        NSDictionary *item = timeline[i];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.001*[item[@"delay"] floatValue] target:self selector:@selector(setColorSequenceFromTimer:) userInfo:item[@"colors"] repeats:NO];
        [_timerArray addObject:timer];
        [_timerDatesArray addObject:timer.fireDate];

        
    }
}

-(void)setColorSequenceFromTimer:(NSTimer *)sender
{
    NSArray *colors = sender.userInfo;
    self.currentColorSequence = colors;
    for (int i=0;i<colors.count;i++) {
        NSString *color = colors[i];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.001*i*_timeToShow/colors.count target:self selector:@selector(setRingingColorFromTimer:) userInfo:color repeats:NO];
        [_timerArray addObject:timer];
        [_timerDatesArray addObject:timer.fireDate];

    }
    _resetToStaticTimer = [NSTimer scheduledTimerWithTimeInterval:0.001*_timeToShow target:self selector:@selector(setStaticClockFromTimer:) userInfo:@"green" repeats:NO];
}

-(void)setRingingColorFromTimer:(NSTimer *)sender
{
    NSString *color = sender.userInfo;
    self.isRinging = YES;
    self.currentColor = color;
    [self updatePicture];
    self.identifier = [NSString stringWithFormat:@"%i_%i",self.tag,_shownCounter];
    [self.delegate showedRingingClockInClockView:self];
    _shownCounter++;
}

-(void)setStaticClockFromTimer:(NSTimer *)sender
{
    NSString *color = sender.userInfo;
    self.isRinging = NO;
    self.currentColor = color;
    [self updatePicture];
}
-(void)pause
{
    for (int i=0;i<_timerArray.count;i++) {
        NSTimer *timer = _timerArray[i];
        NSLog(@"old fire date: %@", timer.fireDate);
        timer.fireDate = [[NSDate date] dateByAddingTimeInterval:100000];
        NSLog(@"sentinel fire date: %@", timer.fireDate);
    }
    _pauseTime = [NSDate date];
}
-(void)resume
{
    NSTimeInterval difference = [[NSDate date] timeIntervalSinceDate:_pauseTime];
    for (int i=0;i <_timerArray.count;i++) {
        NSTimer *timer = _timerArray[i];
        NSDate *oldDate = _timerDatesArray[i];
        NSDate *newDate = [oldDate dateByAddingTimeInterval:difference];
        NSLog(@"difference: %f", difference);
        [timer setFireDate:newDate];
        NSLog(@"OLD date: %@", oldDate);
        NSLog(@"NEW date: %@", newDate);
        NSLog(@"new fire date: %@", timer.fireDate);

    }
    _pauseTime = nil;
}

@end
