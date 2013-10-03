//
//  TPStageViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/30/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPGameViewController.h"

@interface TPStageViewController : UIViewController

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, weak) TPGameViewController *gameVC;

@property (nonatomic, strong) NSMutableArray *eventArray;

@property (nonatomic, assign) int score;

-(void)logEventToServer:(NSDictionary *)event;

-(void)logLevelStarted;
-(void)logLevelCompleted;

-(void)logLevelStartedWithAdditionalData:(NSDictionary *)data;
-(void)logLevelCompletedWithAdditionalData:(NSDictionary *)data summary:(NSDictionary *)summaryData;


-(void)stageOver;


-(long long)epochTimeNow;

@end
