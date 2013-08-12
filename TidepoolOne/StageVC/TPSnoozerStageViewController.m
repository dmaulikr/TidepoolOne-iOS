//
//  TPSnoozerStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerStageViewController.h"

@interface TPSnoozerStageViewController ()
{
    NSMutableArray *_clockViews;
    TPSnoozerClockView *_ringingClockView;
    int _correctTouches;
    int _incorrectTouches;
    NSMutableArray *_eventArray;
}
@end

@implementation TPSnoozerStageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    NSLog([self.data description]);
    //TODO: find better way
    self.view.frame = CGRectOffset(self.view.frame, 0, -20.0);
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:186/255.0 blue:60/255.0 alpha:1.0];    
    _clockViews = [NSMutableArray array];
    self.numRows = 3;
    self.numColumns = 2;
    self.numChoices = 0;
    self.numChoicesTotal = 1;
    _eventArray = [NSMutableArray array];
    self.type = @"snoozer";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    int boxHeight = self.view.bounds.size.height / self.numRows;
    int boxWidth = self.view.bounds.size.width / self.numColumns;
    for (int i=0; i<self.numColumns; i++) {
        for (int j=0; j<self.numRows; j++) {
            TPSnoozerClockView *clockView = [[TPSnoozerClockView alloc] initWithFrame:CGRectMake(i*boxWidth, j*boxHeight, boxWidth, boxHeight)];
            clockView.isRinging = NO;
            clockView.delegate = self;
            clockView.timeline = @[@{@"delay":@100,@"colors":@[@"green"],},
                                   @{@"delay":@2400,@"colors":@[@"red",@"green"],},
                                   @{@"delay":@6400,@"colors":@[@"green"],},
                                   @{@"delay":@9400,@"colors":@[@"green"],},
                                   @{@"delay":@12400,@"colors":@[@"green"],},
                                   @{@"delay":@15400,@"colors":@[@"red",@"green"],},
                                   ];
            clockView.correctColor = @"green";
            clockView.correctColorSequence = @[@"red",@"green"];
            clockView.tag = i+j+1;
            [self.view addSubview:clockView];
            [_clockViews addObject:clockView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tappedClockView:(TPSnoozerClockView *)clockView correctly:(BOOL)correct
{
    if (correct) {
        [self logCorrectClockClickedForClock:clockView];
    } else {
        [self logWrongClockClickedForClock:clockView];
    }
}

-(void)showedPossibleClockInClockView:(TPSnoozerClockView *)clockView
{
    [self logClockRingForClock:clockView];
}

-(void)stageOver
{
    NSLog(@"correct:%i, incorrect:%i", _correctTouches, _incorrectTouches);
    [self.gameVC currentStageDoneWithEvents:_eventArray];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *eventWithTime = [event mutableCopy];
    [eventWithTime setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"time"];
    [_eventArray addObject:eventWithTime];
}
-(void)logTestStartedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_started" forKey:@"event"];
    [self logEventToServer:event];
}

-(void)logClockRingForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"shown" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    [self logEventToServer:event];
}

-(void)logCorrectClockClickedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"correct" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    [self logEventToServer:event];
}

-(void)logWrongClockClickedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"incorrect" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    [self logEventToServer:event];
}

-(void)logTestCompletedForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_completed" forKey:@"event"];
    [self logEventToServer:event];
    [event setValue:@"level_summary" forKey:@"event"];
    [self logEventToServer:event];
    [self stageOver];
}


@end
