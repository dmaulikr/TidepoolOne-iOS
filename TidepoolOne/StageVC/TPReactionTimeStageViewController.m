//
//  TPReactionTimeStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeStageViewController.h"
#import "TPReactionTimeStageCircleView.h"
#import "TPOverlayView.h"

@interface TPReactionTimeStageViewController ()
{
    TPReactionTimeStageCircleView *_circleView;
    NSArray *_sequence;
    int _sequenceNo;
    NSTimer *_colorChangeTimer;
    NSDictionary *_colors;
    UIColor *_previousColor;
    NSString *_sequenceType;
    BOOL _currentCircleTapped;
}
@end

@implementation TPReactionTimeStageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentCircleTapped = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _circleView = [[TPReactionTimeStageCircleView alloc] initWithFrame:self.view.frame];
    _circleView.delegate = self;
    _circleView.radius = 60;
    [self.view addSubview:_circleView];
    
    _sequenceNo = -1;
    _colors = @{@"red":[UIColor redColor],
                @"green":[UIColor greenColor],
                @"yellow":[UIColor yellowColor],
                };
    [self showInstructions];
}


-(void)showInstructions
{
    NSString *imageName;
    if ([@"simple"isEqualToString:self.data[@"sequence_type"]]) {
        imageName = @"reaction_time_disc_a.jpg";
    } else if ([@"complex"isEqualToString:self.data[@"sequence_type"]]) {
        imageName = @"reaction_time_disc_b.jpg";        
    }
    TPOverlayView *overlayView = [[TPOverlayView alloc] initWithFrame:self.view.bounds];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    [overlayView addSubview:imgView];
    [overlayView setCompletionBlock:^{
        [self setupGameForCurrentStage];
    }];
    [self.view addSubview:overlayView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGameForCurrentStage
{
    _sequence = self.data[@"sequence"];
    _sequenceType = self.data[@"sequence_type"];
    _sequenceNo = -1;
    _circleView.color = [UIColor lightGrayColor];
    [self logTestStarted];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(nextCircleColor) userInfo:nil repeats:NO];
}


-(void)circleViewWasTapped
{
    if (_currentCircleTapped) {
        return;
    }
    _currentCircleTapped = YES;
    BOOL correctCircleTapped = NO;
    if ([_sequenceType isEqualToString:@"simple"]) {
        UIColor *color = _colors[@"red"];
        if ([[_circleView color] isEqual:color]) {
            correctCircleTapped = YES;
        } else {
            correctCircleTapped = NO;
        }
    } else if ([_sequenceType isEqualToString:@"complex"]) {
        UIColor *color = _colors[@"red"];
        if ([[_circleView color] isEqual:color]
            && [_previousColor isEqual:_colors[@"yellow"]]
            ) {
            correctCircleTapped = YES;
        } else {
            correctCircleTapped = NO;
        }
    }
    
    if (correctCircleTapped) {
        [self logCorrectCircleClicked];
        _colorChangeTimer.fireDate = [_colorChangeTimer.fireDate dateByAddingTimeInterval:_circleView.animationDuration];
        [_circleView animateCirclePress];
    } else {
        [self logWrongCircleClicked];
    }
}

-(void)nextCircleColor
{
    _currentCircleTapped = NO;
    _sequenceNo++;
    if (_sequenceNo == _sequence.count) {
        [self logTestCompleted];
        [self.gameVC currentStageDone];
        return;
    }
    _previousColor = _circleView.color;
    _circleView.color = _colors[_sequence[_sequenceNo][@"color"]];
    _colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:[_sequence[_sequenceNo][@"interval"] floatValue]*0.001 target:self selector:@selector(nextCircleColor) userInfo:nil repeats:NO];
    [self logCircleShow];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [completeEvents setValue:@"reaction_time" forKey:@"module"];
    [completeEvents setValue:_sequenceType forKey:@"sequence_type"];
    if (_sequenceNo > -1) {
        [completeEvents setValue:[NSNumber numberWithDouble:_sequenceNo] forKey:@"sequence_no"];
    }
    [self.gameVC logEvent:completeEvents];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_started" forKey:@"event_desc"];
    NSMutableArray *colorSequence = [NSMutableArray array];
    for (NSDictionary *item in _sequence) {
        NSString *customString = [NSString stringWithFormat:@"%@:%@", item[@"color"], item[@"interval"]];
        [colorSequence addObject:customString];
    }
    [event setValue:colorSequence forKey:@"color_sequence"];
    [self logEventToServer:event];
}

-(void)logCircleShow
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"circle_shown" forKey:@"event_desc"];
    [event setValue:_sequence[_sequenceNo][@"color"] forKey:@"circle_color"];
    [event setValue:_sequence[_sequenceNo][@"interval"] forKey:@"time_interval"];
    [self logEventToServer:event];
}

-(void)logCorrectCircleClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"correct_circle_clicked" forKey:@"event_desc"];
    [event setValue:_sequence[_sequenceNo][@"color"] forKey:@"circle_color"];
    [self logEventToServer:event];
}

-(void)logWrongCircleClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"wrong_circle_clicked" forKey:@"event_desc"];
    [event setValue:_sequence[_sequenceNo][@"color"] forKey:@"circle_color"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_completed" forKey:@"event_desc"];
    [self logEventToServer:event];
}

@end
