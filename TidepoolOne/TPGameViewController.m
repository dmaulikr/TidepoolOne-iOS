//
//  TPGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGameViewController.h"
#import "TPSurveyStageViewController.h"
#import "TPReactionTimeStageViewController.h"
#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import "TPReactionTimeResultViewController.h"
#import "TPEmotionsCirclesStageViewController.h"

@interface TPGameViewController ()
{
    TPOAuthClient *_oauthClient;
    NSDictionary *_response;
    NSArray *_results;
    int _stage;
    NSNumber *_gameId;
    NSNumber *_userId;

}
@end

@implementation TPGameViewController

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
    _oauthClient = [TPOAuthClient sharedClient];
}


-(void)startNewGame
{
    _stage = 0;
    if (self.childViewControllers.count) {
        UIViewController *currentVC = self.childViewControllers[0];
        [currentVC.view removeFromSuperview];
        [currentVC removeFromParentViewController];
    }
    [_oauthClient postPath:[NSString stringWithFormat:@"api/v1/users/-/games?def_id=%@", self.type] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"got game succesffully");
        
        _response = responseObject[@"data"];
//        _response = responseObject;
        [self setupGameForCurrentStage];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error in getting game");
        NSLog([error description]);
    }];
}


-(void)setupGameForCurrentStage
{
    _gameId = _response[@"id"];
    _userId = _response[@"user_id"];
    NSString *viewName = _response[@"stages"][_stage][@"view_name"];
    if ([viewName isEqualToString:@"Survey"]) {
        [self createSurveyStage];
    } else if ([viewName isEqualToString:@"ReactionTime"]) {
        [self createReactionTimeStage];
    } else if ([viewName isEqualToString:@"EmotionsCircles"]) {
        [self createEmotionsCirclesStage];
    }

}

-(void)createEmotionsCirclesStage
{
    TPEmotionsCirclesStageViewController *emotionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EmotionsCircles"];
    emotionsVC.data = _response[@"stages"][_stage][@"circles"];
    emotionsVC.gameVC = self;
    
    [self addChildViewController:emotionsVC];
    [self.view addSubview:emotionsVC.view];
}


-(void)createSurveyStage
{
    TPSurveyStageViewController *surveyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"survey"];
    surveyVC.data = _response[@"stages"][_stage][@"data"];
    surveyVC.gameVC = self;
    
    [self addChildViewController:surveyVC];
    [self.view addSubview:surveyVC.view];
}


-(void)createReactionTimeStage
{
    TPReactionTimeStageViewController *reactionTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reactiontime"];
    reactionTimeVC.data = _response[@"stages"][_stage];
    reactionTimeVC.gameVC = self;
    
    [self addChildViewController:reactionTimeVC];
    [self.view addSubview:reactionTimeVC.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)currentStageDone
{
    UIViewController *currentVC = self.childViewControllers[0];
    [currentVC.view removeFromSuperview];
    [currentVC removeFromParentViewController];
    _stage++;
    if (_stage < [_response[@"stages"] count]) {
        [self setupGameForCurrentStage];
    } else {
        [self getResults];
    }
}

-(void)showResults
{
    for (NSDictionary *result in _results) {
        NSString *resultType = result[@"type"];
        if ([resultType isEqualToString:@"ReactionTimeResult"]) {
            TPReactionTimeResultViewController *resultVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReactionTimeResult"];
            resultVC.result = result;
            [self addChildViewController:resultVC];
            [self.view addSubview:resultVC.view];
        }
    }
}

#pragma mark polling and obtaining Results

-(void)getResults
{
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    [oauthClient getPath:[NSString stringWithFormat:@"api/v1/users/-/games/%@/results", _gameId] parameters:nil success:^(AFHTTPRequestOperation *operation, id dataObject) {
        NSLog(@"suxess: %@", [dataObject description]);
        NSString *state = [[dataObject valueForKey:@"status"] valueForKey:@"state"];
        if ([state isEqualToString:@"pending"]) {
            [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(pollForResultsForStatus:) userInfo:dataObject repeats:NO];
        } else {
            _results = dataObject[@"data"];
            [self showResults];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail: %@", [error description]);
    }];
}

-(void)pollForResultsForStatus:(NSTimer *)sender
{
    NSDictionary *dataObject = [sender userInfo];
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    //constructing link manually due to the link parameter
    NSMutableURLRequest *request = [[oauthClient requestWithMethod:@"get" path:nil parameters:nil] mutableCopy];
    [request setURL:[NSURL URLWithString:dataObject[@"status"][@"link"]]];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *data, id JSON) {
        NSDictionary *dataObject = JSON;
        NSString *state = dataObject[@"status"][@"state"];
        if ([state isEqualToString:@"pending"]) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pollForResultsForStatus:) userInfo:dataObject repeats:NO];
        } else if ([state isEqualToString:@"done"]) {
            [self getResults];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *data, NSError *error, id JSON) {
        NSLog(@"f:%@", [data description]);
    }];
    [oauthClient enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)op];
}

-(void)logEvent:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [completeEvents setValue:[NSNumber numberWithLongLong:[self epochTimeNow]]
                                        forKey:@"record_time"];
    [completeEvents setValue:_gameId forKey:@"game_id"];
//    [completeEvents setValue:_userId forKey:@"user_id"];
    [completeEvents setValue:[NSNumber numberWithInt:_stage] forKey:@"stage"];

    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    oauthClient.parameterEncoding = AFJSONParameterEncoding;
    [oauthClient postPath:@"/api/v1/user_events" parameters:completeEvents success:^(AFHTTPRequestOperation *operation, id dataObject) {
        NSLog(@"event logging:%@", [dataObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@", [error description]);
    }];
}

-(long long)epochTimeNow
{
    NSNumber *epochTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    return epochTime.longLongValue;
}

@end
