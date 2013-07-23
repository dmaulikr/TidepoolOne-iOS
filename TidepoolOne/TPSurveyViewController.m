//
//  TPSurveyViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSurveyViewController.h"

@interface TPSurveyViewController ()
{
    NSMutableArray *_surveyQuestions;
}
@end

@implementation TPSurveyViewController

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
    _surveyQuestions = [self.data mutableCopy];
    NSLog([_surveyQuestions description]);
    for (int i = 0;i<_surveyQuestions.count;i++) {
        NSMutableDictionary *question = [_surveyQuestions[i] mutableCopy];
        [_surveyQuestions replaceObjectAtIndex:i withObject:question];
        int sliderHeight = 10;
        int sliderWidth = 250;
        int labelHeight = 30;
        int labelWidth = sliderWidth;
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - sliderWidth) / 2, (i+0.5)*(self.view.bounds.size.height) / _surveyQuestions.count - labelHeight, labelWidth, labelHeight)];
        questionLabel.text = question[@"question"];
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - sliderWidth) / 2, (i+0.5)*(self.view.bounds.size.height) / _surveyQuestions.count, sliderWidth, sliderHeight)];
        [question setValue:slider forKey:@"slider"];
        [self.view addSubview:questionLabel];
        [self.view addSubview:slider];
    }

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.titleLabel.text = @"Done";
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 50, 20);
    [self.view addSubview:doneButton];
    [self logTestStarted];
}

-(void)doneButtonPressed
{
    [self logTestCompleted];
    [self.gameVC currentStageDone];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *completeEvents = [event mutableCopy];
    [self.gameVC logEvent:completeEvents];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_started" forKey:@"event_desc"];
    [self logEventToServer:event];
}

-(void)logTestCompleted
{
    NSMutableArray *questions = [NSMutableArray array];
    for (NSDictionary *surveyQuestion in _surveyQuestions) {
        NSMutableDictionary *question = [NSMutableDictionary dictionary];
        [question setValue:surveyQuestion[@"question_id"] forKey:@"question_id"];
        [question setValue:surveyQuestion[@"question_topic"] forKey:@"question_topic"];
        UISlider *slider = surveyQuestion[@"slider"];
        int steps = [surveyQuestion[@"steps"] intValue];
        float scaledValue = 1 + (slider.value * (steps - 1));
        [question setValue:[NSNumber numberWithInt:(int)(scaledValue + 0.5)] forKey:@"answer"];
        [questions addObject:question];
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"test_completed" forKey:@"event_desc"];
    [event setValue:questions forKey:@"questions"];
    [self logEventToServer:event];
}

@end
