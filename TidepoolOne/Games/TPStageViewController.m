//
//  TPStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/30/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPStageViewController.h"

@interface TPStageViewController ()
@end

@implementation TPStageViewController

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
    _eventArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stageOver
{
    [self logTestCompleted];
    [self.gameVC currentStageDoneWithEvents:self.eventArray];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *eventWithTime = [event mutableCopy];
    [eventWithTime setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"time"];
    [self.eventArray addObject:eventWithTime];
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
    [self logEventToServer:event];
}



-(long long)epochTimeNow
{
    NSNumber *epochTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    return epochTime.longLongValue;
}


@end
