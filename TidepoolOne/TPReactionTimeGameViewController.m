//
//  TPReactionTimeGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeGameViewController.h"
#import "TPReactionTimeGameCircleView.h"
#import "TPUploadQueue.h"
#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>

@interface TPReactionTimeGameViewController ()
{
    TPUploadQueue *_uploadQueue;
    TPReactionTimeGameCircleView *_circleView;
    NSArray *stages;
    NSArray *_sequence;
    int stage;
    int sequenceNo;
    NSTimer *colorChangeTimer;
    NSDictionary *_colors;
    UIColor *previousColor;
    NSNumber *_gameId;
    NSNumber *_userId;
    NSString *_sequenceType;

}
@end

@implementation TPReactionTimeGameViewController

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
    _uploadQueue = [[TPUploadQueue alloc] init];
    _circleView = [[TPReactionTimeGameCircleView alloc] initWithFrame:self.view.frame];
    _circleView.delegate = self;
    [self.view addSubview:_circleView];
    stage = 1;    
    [self setupGameForCurrentStage];
    sequenceNo = -1;
    _colors = @{@"red":[UIColor redColor],
                @"green":[UIColor greenColor],
                @"yellow":[UIColor yellowColor],
                };
    _circleView.radius = 60;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGameForCurrentStage
{
    if ([_response[@"stages"][stage][@"view_name"] isEqualToString:@"ReactionTime"]) {
        NSLog([_response[@"stages"] description]);
        _sequence = _response[@"stages"][stage][@"sequence"];
        _gameId = _response[@"id"];
        _userId = _response[@"user_id"];
        _sequenceType = _response[@"stages"][stage][@"sequence_type"];
        sequenceNo = 0;
        _circleView.color = [UIColor lightGrayColor];
        [self logTestStarted];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(nextCircleColor) userInfo:nil repeats:NO];
    }
}


-(void)circleViewWasTapped
{
    switch (stage) {
        case 0:
            break;
        case 1:
        case 2:
        {
            UIColor *color = _colors[@"red"];
            if ([[_circleView color] isEqual:color]) {
                [self logCorrectCircleClicked];
                [_circleView animateCirclePress];
            } else {
                [self logWrongCircleClicked];
                return;
            }
        }
            break;
        default:
            break;
    }
}

-(void)nextCircleColor
{
//    if (colorChangeTimerActive) {
    {
        sequenceNo++;
        if (sequenceNo == _sequence.count) {
            [self logTestCompleted];
            stage ++;
            if (stage < [self.response[@"stages"] count]) {
                [self setupGameForCurrentStage];
            } else {
                [self getResults];
            }
            return;
        }
//        previousColor = circleLayer.fillColor];
        _circleView.color = _colors[_sequence[sequenceNo][@"color"]];
        colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:[_sequence[sequenceNo][@"interval"] floatValue]*0.001 target:self selector:@selector(nextCircleColor) userInfo:nil repeats:NO];
        [self logCircleShow];
    }
}

-(void)pollForResultsForStatus:(NSTimer *)sender
{
    NSLog(@"sender: %@", [sender description]);
    NSDictionary *responseObject = [sender userInfo];
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    NSMutableURLRequest *request = [[oauthClient requestWithMethod:@"get" path:nil parameters:nil] mutableCopy];
    [request setURL:[NSURL URLWithString:responseObject[@"status"][@"link"]]];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"s:%@", [JSON description]);
        NSDictionary *responseObject = JSON;
        if ([@"pending" isEqualToString:responseObject[@"status"][@"state"]]) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pollForResultsForStatus:) userInfo:responseObject repeats:NO];
        } else {
            NSLog(@"DONE");
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"f:%@", [response description]);
    }];
    [oauthClient enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)op];
}


#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    oauthClient.parameterEncoding = AFJSONParameterEncoding;
    NSURLRequest *request = [oauthClient requestWithMethod:@"post" path:@"/api/v1/user_events" parameters:event];
    NSLog([NSString stringWithUTF8String:[[request HTTPBody] bytes]]);
    [[TPOAuthClient sharedClient] postPath:@"/api/v1/user_events" parameters:event success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"success:%@", [responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@", [error description]);
    }];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@0 forKey:@"event_type"];
    [event setValue:@"reaction_time" forKey:@"module"];
    [event setValue:@0 forKey:@"stage"];
    [event setValue:_sequenceType forKey:@"sequence_type"];
    [event setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"record_time"];
    [event setValue:@"test_started" forKey:@"event_desc"];
    [event setValue:_sequence forKey:@"color_sequence"];
    [event setValue:_gameId forKey:@"game_id"];
    [event setValue:_userId forKey:@"user_id"];
    [self logEventToServer:event];
}

-(void)logCircleShow
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@0 forKey:@"event_type"];
    [event setValue:@"reaction_time" forKey:@"module"];
    [event setValue:@0 forKey:@"stage"];
    [event setValue:_sequenceType forKey:@"sequence_type"];
    [event setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"record_time"];
    [event setValue:@"circle_shown" forKey:@"event_desc"];
    [event setValue:_gameId forKey:@"game_id"];
    [event setValue:_userId forKey:@"user_id"];
    
    [event setValue:[NSNumber numberWithDouble:sequenceNo] forKey:@"sequence_no"];
    [event setValue:_sequence[sequenceNo][@"color"] forKey:@"circle_color"];
    [event setValue:_sequence[sequenceNo][@"interval"] forKey:@"time_interval"];
    [self logEventToServer:event];
}

-(void)logCorrectCircleClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@0 forKey:@"event_type"];
    [event setValue:@"reaction_time" forKey:@"module"];
    [event setValue:@0 forKey:@"stage"];
    [event setValue:_sequenceType forKey:@"sequence_type"];
    [event setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"record_time"];
    [event setValue:@"correct_circle_clicked" forKey:@"event_desc"];
    [event setValue:_gameId forKey:@"game_id"];
    [event setValue:_userId forKey:@"user_id"];
    [event setValue:[NSNumber numberWithDouble:sequenceNo] forKey:@"sequence_no"];
    [event setValue:_sequence[sequenceNo][@"color"] forKey:@"circle_color"];
    [self logEventToServer:event];
}

-(void)logWrongCircleClicked
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@0 forKey:@"event_type"];
    [event setValue:@"reaction_time" forKey:@"module"];
    [event setValue:@0 forKey:@"stage"];
    [event setValue:_sequenceType forKey:@"sequence_type"];
    [event setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"record_time"];
    [event setValue:@"wrong_circle_clicked" forKey:@"event_desc"];
    [event setValue:_gameId forKey:@"game_id"];
    [event setValue:_userId forKey:@"user_id"];
    
    [event setValue:[NSNumber numberWithDouble:sequenceNo] forKey:@"sequence_no"];
    [event setValue:_sequence[sequenceNo][@"color"] forKey:@"circle_color"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    //    double epochTime = [[NSDate date] timeIntervalSince1970]*1000;
    //    uint epochTimeInt = (uint)epochTime;
    //    NSLog(@"%f,%ui",epochTime,epochTimeInt);
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@0 forKey:@"event_type"];
    [event setValue:@"reaction_time" forKey:@"module"];
    [event setValue:@0 forKey:@"stage"];
    [event setValue:_sequenceType forKey:@"sequence_type"];
    [event setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"record_time"];
    [event setValue:@"test_completed" forKey:@"event_desc"];
    [event setValue:[NSNumber numberWithDouble:sequenceNo] forKey:@"sequence_no"];
    [event setValue:_gameId forKey:@"game_id"];
    [event setValue:_userId forKey:@"user_id"];
    [self logEventToServer:event];
}

-(long long)epochTimeNow
{
    NSNumber *epochTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    NSLog(@"epochh:%@, %lld", [epochTime description], epochTime.longLongValue);
    //    NSLog([epochTime intValue]);
    return epochTime.longLongValue;
    
}

-(void)getResults
{
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    [oauthClient getPath:[NSString stringWithFormat:@"api/v1/users/-/games/%@/results", _gameId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"suxess: %@", [responseObject description]);
        [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(pollForResultsForStatus:) userInfo:responseObject repeats:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail: %@", [error description]);
    }];
}

@end
