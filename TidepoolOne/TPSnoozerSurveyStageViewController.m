//
//  TPSnoozerSurveyStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerSurveyStageViewController.h"

@interface TPSnoozerSurveyStageViewController ()
{
    NSMutableArray *_eventArray;
}
@end

@implementation TPSnoozerSurveyStageViewController

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
    // Do any additional setup after loading the view from its nib.
    self.type = @"survey";
    [self parseData];
    _eventArray = [NSMutableArray array];
    [self logTestStarted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)parseData
{
    for (NSDictionary *item in self.data) {
        NSString *questionType = item[@"topic"];
        if ([questionType isEqualToString:@"activity"]) {
            self.activityQuestion = item[@"question"];
        } else if ([questionType isEqualToString:@"sleep"]) {
            self.sleepQuestion = item[@"question"];
        }
    }
}

- (IBAction)submitStage:(id)sender {
    [self logTestCompleted];
    [self.gameVC currentStageDoneWithEvents:_eventArray];
}

- (IBAction)sleepMoved:(id)sender {
    [self logSleepChanged];
}

- (IBAction)activityMoved:(id)sender {
    [self logActivityChanged];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *eventWithTime = [event mutableCopy];
    [eventWithTime setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"time"];
    [_eventArray addObject:eventWithTime];
}

-(void)logSleepChanged
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"changed" forKey:@"event"];
    [event setValue:@"sleep1-7" forKey:@"question_id"];
    [event setValue:@"sleep" forKey:@"topic"];
    [event setValue:[NSNumber numberWithInt:self.sleepSlider.value*7.9999] forKey:@"answer"];
    [self logEventToServer:event];
}

-(void)logActivityChanged
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"changed" forKey:@"event"];
    [event setValue:@"activity1-7" forKey:@"question_id"];
    [event setValue:@"activity" forKey:@"topic"];
    [event setValue:[NSNumber numberWithInt:self.sleepSlider.value*7.9999] forKey:@"answer"];
    [self logEventToServer:event];
}


-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_started" forKey:@"event"];
    [event setValue:self.data[@"game_type"] forKey:@"sequence_type"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_completed" forKey:@"event"];
    [self logEventToServer:event];
    [event setValue:@"level_summary" forKey:@"event"];
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:@{@"question_id":@"activity1-7",@"topic":@"activity",@"answer":[NSNumber numberWithInt:self.sleepSlider.value*7.9999]}];
    [data addObject:@{@"question_id":@"sleep1-7",@"topic":@"sleep",@"answer":[NSNumber numberWithInt:self.sleepSlider.value*7.9999]}];
    [event setValue:data forKey:@"data"];
    [self logEventToServer:event];
}


@end
