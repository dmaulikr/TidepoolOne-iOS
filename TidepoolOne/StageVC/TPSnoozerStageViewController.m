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
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:186/255.0 blue:60/255.0 alpha:1.0];
    _clockViews = [NSMutableArray array];
    self.numRows = 2;
    self.numColumns = 2;
    self.numChoices = 0;
    self.numChoicesTotal = 10;
}

- (void)viewDidAppear:(BOOL)animated
{
    int boxHeight = self.view.bounds.size.height / self.numRows;
    int boxWidth = self.view.bounds.size.width / self.numColumns;
    for (int i=0; i<self.numColumns; i++) {
        for (int j=0; j<self.numRows; j++) {
            TPSnoozerClockView *clockView = [[TPSnoozerClockView alloc] initWithFrame:CGRectMake(i*boxWidth, j*boxHeight, boxWidth, boxHeight)];
            clockView.isRinging = NO;
            clockView.delegate = self;
            [self.view addSubview:clockView];
            [_clockViews addObject:clockView];
        }
    }
    [self startGameTimer];
}

-(void)startGameTimer
{
    if (_numChoices < _numChoicesTotal) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(makeRandomClockRing) userInfo:nil repeats:NO];
        _numChoices++;
    }
}

-(void)makeRandomClockRing
{
    _ringingClockView.isRinging = NO;
    TPSnoozerClockView *newRingingClock = _clockViews[rand()%_clockViews.count];
    while (newRingingClock == _ringingClockView) {
        newRingingClock = _clockViews[rand()%_clockViews.count];
    }
    _ringingClockView = newRingingClock;
    _ringingClockView.isRinging = YES;
    [self startGameTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clockView:(TPSnoozerClockView *)clockView wasTouchedCorrectly:(BOOL)correct
{
    if (correct) {
        _correctTouches++;
    } else {
        _incorrectTouches++;
    }
    if (_numChoices == _numChoicesTotal) {
        [self stageOver];
    }
}

-(void)stageOver
{
    NSLog(@"correct:%i, incorrect:%i", _correctTouches, _incorrectTouches);
    [self.gameVC currentStageDone];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [completeEvents setValue:@"snoozer" forKey:@"module"];
    [self.gameVC logEvent:completeEvents];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_started" forKey:@"event_desc"];
    [self logEventToServer:event];
}

-(void)logClockRing
{
    
}

-(void)logCorrectClockClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"correct_circle_clicked" forKey:@"event_desc"];
    [self logEventToServer:event];
}

-(void)logWrongClockClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"wrong_circle_clicked" forKey:@"event_desc"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_completed" forKey:@"event_desc"];
    [self logEventToServer:event];
}


@end
