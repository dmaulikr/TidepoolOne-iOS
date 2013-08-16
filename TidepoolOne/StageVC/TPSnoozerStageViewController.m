//
//  TPSnoozerStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/1/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSnoozerStageViewController.h"
#import "TPSnoozerInstructionViewController.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>

@interface TPSnoozerStageViewController ()
{
    NSMutableArray *_clockViews;
    TPSnoozerClockView *_ringingClockView;
    int _correctTouches;
    int _incorrectTouches;
    NSMutableArray *_eventArray;
    TPSnoozerInstructionViewController *_instructionVC;
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
    self.view.backgroundColor = [UIColor clearColor];
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
    [self showInstructionScreen];
}

-(void)showInstructionScreen
{
    _instructionVC = [[TPSnoozerInstructionViewController alloc] initWithNibName:@"TPSnoozerInstructionViewController" bundle:nil];
    _instructionVC.view.frame = self.view.frame;
    _instructionVC.stageVC = self;
    _instructionVC.levelNumberLabel.text = [NSString stringWithFormat:@"%i", self.gameVC.stage+1];
    _instructionVC.instructionsTitleLabel.text = @"title";
    _instructionVC.instructionsDetailLabel.attributedText = [self parsedFromMarkdown:self.data[@"instructions"]];
    _instructionVC.clockViewLeft.currentColor = self.data[@"correct_color_sequence"][0];
    _instructionVC.clockViewRight.currentColor = [self.data[@"correct_color_sequence"] lastObject];
    [_instructionVC.clockViewLeft updatePicture];
    [_instructionVC.clockViewRight updatePicture];
    if (self.gameVC.stage > 0) {
        [self.view addSubview:_instructionVC.view];
        _instructionVC.view.alpha = 0.0;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _instructionVC.view.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.view addSubview:_instructionVC.view];        
    }

}

-(void)instructionDone
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _instructionVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self layoutClocks];        
        [_instructionVC.view removeFromSuperview];
        [self createTimerForStageEnd];
        [self logTestStarted];
    }];
}

-(void)layoutClocks
{
    int boxHeight = self.view.bounds.size.height / self.numRows;
    int boxWidth = self.view.bounds.size.width / self.numColumns;
    NSArray *shuffledTimeline = [self shuffleArray:self.data[@"sequence"]];
    for (int i=0; i<self.numColumns; i++) {
        for (int j=0; j<self.numRows; j++) {
            TPSnoozerClockView *clockView = [[TPSnoozerClockView alloc] initWithFrame:CGRectMake(i*boxWidth, j*boxHeight, boxWidth, boxHeight)];
            clockView.isRinging = NO;
            clockView.delegate = self;
            clockView.timeline = shuffledTimeline[self.numRows*i+j];
            clockView.correctColor = self.data[@"correct_color"];
            clockView.correctColorSequence = self.data[@"correct_color_sequence"];
            clockView.tag = self.numRows*i+j+1;
            [self.view addSubview:clockView];
            [_clockViews addObject:clockView];
        }
    }
}


-(NSArray *)shuffleArray:(NSArray *)array
{
    NSMutableArray *shuffledArray = [array mutableCopy];
    for (int i=0;i<shuffledArray.count;i++) {
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:(i+(arc4random()%(shuffledArray.count-i)))];
    }
    return shuffledArray;
}


-(void)createTimerForStageEnd
{
    NSNumber *maxTime = @0;
    for (NSArray *clockSequence in self.data[@"sequence"]) {
        for (NSDictionary *item in clockSequence) {
            if ([maxTime intValue] < [item[@"delay"] intValue]) {
                maxTime = item[@"delay"];
            }
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0 + maxTime.floatValue/1000 target:self selector:@selector(stageOver) userInfo:nil repeats:NO];
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

-(void)showedRingingClockInClockView:(TPSnoozerClockView *)clockView
{
    [self logClockRingForClock:clockView];
}

-(void)showedPossibleClockInClockView:(TPSnoozerClockView *)clockView
{
    [self logClockRingForClock:clockView];
}

-(void)stageOver
{
    [self logTestCompleted];
    [self.gameVC currentStageDoneWithEvents:_eventArray];
}

#pragma mark Logging functions

-(void)logEventToServer:(NSDictionary *)event
{
    NSMutableDictionary *eventWithTime = [event mutableCopy];
    [eventWithTime setValue:[NSNumber numberWithLongLong:[self epochTimeNow]] forKey:@"time"];
    [_eventArray addObject:eventWithTime];
}
-(void)logTestStarted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_started" forKey:@"event"];
    [event setValue:self.data[@"game_type"] forKey:@"sequence_type"];
    [self logEventToServer:event];
}

-(void)logClockRingForClock:(TPSnoozerClockView *)clockView
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"shown" forKey:@"event"];
    [event setValue:clockView.identifier forKey:@"item_id"];
    if ([clockView isTarget]) {
        [event setValue:@"target" forKey:@"type"];
        NSLog(@"ring target");
    } else {
        [event setValue:@"decoy" forKey:@"type"];
        NSLog(@"ring decoy");
    }
    [event setValue:clockView.currentColor forKey:@"color"];
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

-(void)logTestCompleted
{
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setValue:@"level_completed" forKey:@"event"];
    [self logEventToServer:event];
    [event setValue:@"level_summary" forKey:@"event"];
    [self logEventToServer:event];
}

-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
    //    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    NSDictionary *attributes = @{
                                 @(STRONG): @{NSFontAttributeName : strongFont,},
                                 @(EMPH): @{NSForegroundColorAttributeName : emColor,}
                                 };
    // parse the markdown
    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
    
    return prettyText;
    //    // assign it to a view object
    //    myTextView.attributedText = prettyText;
    
}


@end
