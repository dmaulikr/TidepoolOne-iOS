//
//  TPGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/22/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGameViewController.h"
#import "TPOAuthClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TPSnoozerStageViewController.h"

#import "TPSnoozerResultViewController.h"
#import "TPResultViewController.h"
#import "TPSnoozerSurveyStageViewController.h"
#import "TPTabBarController.h"

#import "TPEIStagePickEmotionViewController.h"
#import "TPEIYourMoodViewController.h"
#import "TPEIResultViewController.h"

#import "TPEchoStageViewController.h"
#import "TPEchoResultViewController.h"

#import <UAPush.h>

@interface TPGameViewController ()
{
    TPOAuthClient *_oauthClient;
    NSArray *_results;
    int _stage;
    NSNumber *_gameId;
    NSNumber *_userId;
    NSMutableArray *_eventsForEachStageArray;
    NSTimer *_pollTimeoutTimer;
    NSTimer *_pollTimer;
    int _gameScore;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOutSignal) name:@"Logged Out" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInSignal) name:@"Logged In" object:nil];
    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"view did load %@", self.view);
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

-(void)setGameObject:(id)gameObject
{
    _gameObject = gameObject;
    if (_gameObject) {
        [self setupNewGame];
    }
}

-(void)setupNewGame
{
    _stage = 0;
    _gameScore = 0;
    _eventsForEachStageArray = [NSMutableArray array];
    self.gameStartView.hidden = YES;
    if (self.childViewControllers.count) {
        UIViewController *currentVC = self.childViewControllers[0];
        [self hideContentController:currentVC];
    }
    [self setupGameForCurrentStage];
}

-(void)getNewGame
{
    [self clearCurrentGame];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading new game";
    [_oauthClient getNewGameOfType:self.type WithCompletionHandlersSuccess:^(id dataObject) {
        self.gameObject = dataObject;
        [hud hide:YES];
    } andFailure:^{
        [hud hide:YES];
    }];
}

-(void)clearCurrentGame
{
    [_pollTimer invalidate];
    _pollTimer = nil;
    [_pollTimeoutTimer invalidate];
    _pollTimeoutTimer = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    for (UIViewController *controller in self.childViewControllers) {
        [controller.view removeFromSuperview];
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }
    self.gameObject = nil;
}


-(void)setupGameForCurrentStage
{
    _gameId = self.gameObject[@"id"];
    _userId = self.gameObject[@"user_id"];
    NSString *viewName = self.gameObject[@"stages"][_stage][@"client_view_name"];
    NSDictionary *classDictionary = @{
                                      @"Snoozer":[TPSnoozerStageViewController class],
                                      @"Survey":[TPSnoozerSurveyStageViewController class],
                                      @"FaceOff":[TPEIStagePickEmotionViewController class],
                                      @"EmotionsSurvey":[TPEIYourMoodViewController class],
                                      @"Echo":[TPEchoStageViewController class],
                                      };
    Class stageClass = classDictionary[viewName];
    TPStageViewController *stageVC = [[stageClass alloc] initWithNibName:nil bundle:nil];
    stageVC.gameVC = self;
    stageVC.view.frame = self.view.bounds;
    stageVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    stageVC.data = self.gameObject[@"stages"][_stage];
    self.title = stageVC.title;
    stageVC.score = _gameScore;
    [self displayContentController:stageVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)currentStageDoneWithEvents:(NSArray *)events
{
    TPStageViewController *currentVC = self.childViewControllers[0];
    _gameScore = currentVC.score;
    NSMutableDictionary *stageLog = [NSMutableDictionary dictionary];
    [stageLog setValue:[NSNumber numberWithInt:_stage] forKey:@"stage"];
    [stageLog setValue:events forKey:@"events"];
    [stageLog setValue:currentVC.type forKey:@"event_type"];
    int timeZoneOffsetInMinutes = [[NSTimeZone localTimeZone] secondsFromGMT];
    [stageLog setValue:[NSNumber numberWithInt:timeZoneOffsetInMinutes] forKey:@"timezone_offset"];
    //start------wrap events into global array
    [_eventsForEachStageArray addObject:stageLog];
    //next stage
    [self hideContentController:currentVC];
    _stage++;
    __block typeof(self) bself = self;
    if (_stage < [self.gameObject[@"stages"] count]) {
        [self setupGameForCurrentStage];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Submitting performance...";
        [_oauthClient putPath:[NSString stringWithFormat:@"api/v1/users/-/games/%@/event_log", _gameId] parameters:@{@"event_log":_eventsForEachStageArray} success:^(AFHTTPRequestOperation *operation, id dataObject) {
            [bself getResults];
            [hud hide:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [hud hide:YES];
            [_oauthClient handleError:error withOptionalMessage:@"Couldn't submit events to server"];
            [self clearCurrentGame];
            self.gameStartView.hidden = NO;
        }];
    }
}

-(void)showResults
{
    [[UAPush shared] setPushEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Got New Game Results" object:nil];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary *classDictionary = @{
                                      @"SpeedArchetypeResult":[TPSnoozerResultViewController class],
                                      @"EmoIntelligenceResult":[TPEIResultViewController class],
                                      @"AttentionResult":[TPEchoResultViewController class],
                                      };
    BOOL hasResultsToShow = NO;
    for (NSDictionary *result in _results) {
        NSString *resultType = result[@"type"];
        Class stageClass = classDictionary[resultType];
        TPResultViewController *resultVC = [[stageClass alloc] initWithNibName:nil bundle:nil];
        if (resultVC) {
            hasResultsToShow = YES;
            resultVC.gameVC = self;
            [self displayContentController:resultVC];
            resultVC.result = result;
        }
    }
    if (!hasResultsToShow) {
        [[[UIAlertView alloc] initWithTitle:@"Game error" message:@"There was an error processing game results. Most likely, you did not react at all! Please play again!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self clearCurrentGame];
    self.gameStartView.hidden = NO;
}

#pragma mark polling and obtaining Results

-(void)getResults
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Calculating results";
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    __block typeof(self) bself = self;
    [oauthClient getGameResultsForGameId:_gameId WithCompletionHandlersSuccess:^(id dataObject) {
        NSString *state = [[dataObject valueForKey:@"status"] valueForKey:@"state"];
        if ([state isEqualToString:@"pending"]) {
            _pollTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:bself selector:@selector(pollTimedOut) userInfo:nil repeats:NO];
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:bself selector:@selector(pollForResultsForStatus:) userInfo:dataObject repeats:NO];
        } else {
            [_pollTimeoutTimer invalidate];
            _pollTimeoutTimer = nil;
            _results = dataObject[@"data"];
            [hud hide:YES];
            [self showResults];
        }
    } andFailure:^{
        [hud hide:YES];
        [self clearCurrentGame];
        self.gameStartView.hidden = NO;
    }];
}


-(void)pollTimedOut
{
    [_pollTimer invalidate];
    _pollTimer = nil;
    [[[UIAlertView alloc] initWithTitle:@"Server busy" message:@"The results are taking too long. The results will be populated on the dashboard later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    [self clearCurrentGame];
    self.gameStartView.hidden = NO;
}

-(void)pollForResultsForStatus:(NSTimer *)sender
{
    NSDictionary *dataObject = [sender userInfo];
    TPOAuthClient *oauthClient = [TPOAuthClient sharedClient];
    //constructing link manually due to the link parameter
    NSMutableURLRequest *request = [[oauthClient requestWithMethod:@"get" path:nil parameters:nil] mutableCopy];
    [request setURL:[NSURL URLWithString:dataObject[@"status"][@"link"]]];
    __block typeof(self) bself = self;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *data, id JSON) {
        NSDictionary *dataObject = JSON;
        NSString *state = dataObject[@"status"][@"state"];
        if ([state isEqualToString:@"pending"]) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:bself selector:@selector(pollForResultsForStatus:) userInfo:dataObject repeats:NO];
        } else if ([state isEqualToString:@"done"]) {
            [bself getResults];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *data, NSError *error, id JSON) {
        [_oauthClient handleError:error withOptionalMessage:@"Error polling for results"];
        [self clearCurrentGame];
        self.gameStartView.hidden = NO;
    }];
    [oauthClient enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)op];
}

-(void)logEvent:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [completeEvents setValue:[NSNumber numberWithLongLong:[self epochTimeNow]]
                                        forKey:@"record_time"];
    [completeEvents setValue:_gameId forKey:@"game_id"];
    [completeEvents setValue:[NSNumber numberWithInt:_stage] forKey:@"stage"];

    __block typeof(self) bself = self;
    [_oauthClient postGameEvents:completeEvents withCompletionHandlersSuccess:^{
    } andFailure:^{
        [bself clearCurrentGame];
        bself.gameStartView.hidden = NO;
    }];
}

-(long long)epochTimeNow
{
    NSNumber *epochTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    return epochTime.longLongValue;
}

- (IBAction)playButtonPressed:(id)sender {
    [self getNewGame];
}


#pragma mark Login/Logout notification handlers

-(void)loggedInSignal
{
    
}

-(void)loggedOutSignal
{
    for (UIViewController *child in super.childViewControllers) {
        [self hideContentController:child];
    }
    self.gameStartView.hidden = NO;
}


#pragma mark Container View Controller methods

- (void) displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content];
    content.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];
}

- (void) hideContentController: (UIViewController*) content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

@end
