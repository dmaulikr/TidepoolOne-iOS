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
    NSTimer *_resetToStaticTimer;
    NSTimeInterval _ringingTimeInterval;
    NSMutableDictionary *_imageDictionary;
    CGSize _baseSize;
    CGPoint relativeCenter;
    BOOL _showingResponseImage;
    BOOL _response;
    float _avgTimeToShow;
    int _shownCounter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isRinging = YES;
        self.currentColor = @"green";
        _ringingState = 0;
        _shownCounter = 0;
        _imageDictionary = [NSMutableDictionary dictionary];

        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock.png"] forKey:@"green"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring1.png"] forKey:@"green-ringing-1"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockring2.png"] forKey:@"green-ringing-2"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock-correct.png"] forKey:@"correct"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clock-missed.png"] forKey:@"incorrect"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockb.png"] forKey:@"red"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringb1.png"] forKey:@"red-ringing-1"];
        [_imageDictionary setValue:[UIImage imageNamed:@"snoozer-clockringb2.png"] forKey:@"red-ringing-2"];

        _avgTimeToShow = 2000;
        UIImage *image = _imageDictionary[@"green"];
        _baseSize = image.size;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _baseSize.width, _baseSize.width)];
        relativeCenter.x = self.bounds.size.width/2;
        relativeCenter.y = self.bounds.size.height/2;
        _imageView.center = relativeCenter;
        [self addSubview:_imageView];
        _imageView.animationDuration = 0.25;
    }
    return self;
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
        _showingResponseImage = NO;
    } else {
        if (_isRinging) {
            NSArray *animationImages = @[_imageDictionary[_currentColor],_imageDictionary[[NSString stringWithFormat:@"%@-ringing-1",_currentColor]],_imageDictionary[[NSString stringWithFormat:@"%@-ringing-2",_currentColor]]];
            _imageView.animationImages = animationImages;
            float factor = 1.4;
            _imageView.transform = CGAffineTransformMakeScale(factor, factor);
            [_imageView startAnimating];
        } else {
            [_imageView stopAnimating];
            float factor = 1;
            _imageView.transform = CGAffineTransformMakeScale(factor, factor);
            _imageView.image = _imageDictionary[_currentColor];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_resetToStaticTimer invalidate];
    _resetToStaticTimer = nil;
    _response = [self tappedCorrectly];
    [self.delegate tappedClockView:self correctly:_response];
    _showingResponseImage = YES;
    self.isRinging = NO;
    [self updatePicture];
}

-(BOOL)tappedCorrectly
{
    return _isRinging && ([_currentColor isEqualToString:_correctColor]) && ([_currentColorSequence isEqualToArray:_correctColorSequence]);
}

-(void)setTimeline:(NSArray *)timeline
{
    _timeline = timeline;

    for (int i=0;i<timeline.count;i++) {
        NSDictionary *item = timeline[i];
        [NSTimer scheduledTimerWithTimeInterval:0.001*[item[@"delay"] floatValue] target:self selector:@selector(setColorSequenceFromTimer:) userInfo:item[@"colors"] repeats:NO];
    }
}

-(void)setColorSequenceFromTimer:(NSTimer *)sender
{
    NSArray *colors = sender.userInfo;
    self.currentColorSequence = colors;
    for (int i=0;i<colors.count;i++) {
        NSString *color = colors[i];
        [NSTimer scheduledTimerWithTimeInterval:0.001*i*_avgTimeToShow/colors.count target:self selector:@selector(setRingingColorFromTimer:) userInfo:color repeats:NO];
    }
    _resetToStaticTimer = [NSTimer scheduledTimerWithTimeInterval:0.001*_avgTimeToShow target:self selector:@selector(setStaticClockFromTimer:) userInfo:@"green" repeats:NO];
}

-(void)setRingingColorFromTimer:(NSTimer *)sender
{
    NSString *color = sender.userInfo;
    self.isRinging = YES;
    self.currentColor = color;
    [self updatePicture];
    if ([self tappedCorrectly]) {
        _shownCounter++;
        self.identifier = [NSString stringWithFormat:@"%i_%i",self.tag,_shownCounter];
        [self.delegate showedPossibleClockInClockView:self];
        NSLog(@"yeah");
    }

}

-(void)setStaticClockFromTimer:(NSTimer *)sender
{
    NSString *color = sender.userInfo;
    self.isRinging = NO;
    self.currentColor = color;
    [self updatePicture];
}

@end
