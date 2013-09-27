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
    [self logLevelStarted];
    [self loadDefaults];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics tracker
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Snoozer Survey Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]  build]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)parseData
{
    for (NSDictionary *item in self.data[@"data"]) {
        NSString *questionType = item[@"topic"];
        if ([questionType isEqualToString:@"activity"]) {
            self.activityQuestion.text = item[@"question"];
        } else if ([questionType isEqualToString:@"sleep"]) {
            self.sleepQuestion.text = item[@"question"];
        }
    }
}

- (IBAction)submitStage:(id)sender {
    [self logLevelCompleted];
    [self.gameVC currentStageDoneWithEvents:_eventArray];
}

- (IBAction)sleepMoved:(id)sender {
    [self logSleepChanged];
    [self saveDefaults];
}

- (IBAction)activityMoved:(id)sender {
    [self logActivityChanged];
    [self saveDefaults];    
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


-(void)logLevelStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_started" forKey:@"event"];
    [event setValue:self.data[@"game_type"] forKey:@"sequence_type"];
    [self logEventToServer:event];
}

-(void)logLevelCompleted
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


-(void)saveDefaults
{
    NSDictionary *snoozerStageDefaults = @{
                                           @"sleep":[NSNumber numberWithFloat:self.sleepSlider.value],
                                           @"activity":[NSNumber numberWithFloat:self.activitySlider.value],
                                               };
    [[NSUserDefaults standardUserDefaults] setValue:snoozerStageDefaults forKey:@"SnoozerSurveyStagePreviousValues"];
    
}

-(void)loadDefaults
{
    NSDictionary *snoozerStageDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:@"SnoozerSurveyStagePreviousValues"];
    if (snoozerStageDefaults) {
        self.sleepSlider.value = [snoozerStageDefaults[@"sleep"] floatValue];
        self.activitySlider.value = [snoozerStageDefaults[@"activity"] floatValue];
    }
}

@end
