//
//  TPEchoStageViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoStageViewController.h"
#import "TPEchoCircleView.h"
#import <QuartzCore/QuartzCore.h>

@interface TPEchoStageViewController () <TPEchoCircleViewDelegate>
{
    NSArray *_pattern;
    NSMutableArray *_circles;
    int _currentIndex;
    int _currentMaxIndex;
}
@end

@implementation TPEchoStageViewController

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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.numberContainerView.layer.cornerRadius = self.numberContainerView.bounds.size.width/2;
    self.countdownLabel.font = [UIFont fontWithName:@"Elephant" size:35.0];
    self.type = @"echo";
}

-(void)setReverseMode:(BOOL)reverseMode
{
    _reverseMode = reverseMode;
    if (reverseMode) {
        self.view.backgroundColor = [UIColor blackColor];
        self.numberContainerView.backgroundColor = [UIColor whiteColor];
        self.countdownLabel.textColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.numberContainerView.backgroundColor = [UIColor blackColor];
        self.countdownLabel.textColor = [UIColor whiteColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    self.reverseMode = ([self.data[@"stage_type"] isEqualToString:@"reverse"]);
    _circles = [@[] mutableCopy];
    _currentIndex = 0;
    _currentMaxIndex = 0;
    float radius = 100;
    float viewDimensions = 100;
    int numCircles = 7;
    NSArray *colors = @[
                        [UIColor colorWithRed:64/255.0 green:191/255.0 blue:239/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:205/255.0 blue:2/255.0 alpha:1],
                        [UIColor colorWithRed:231/255.0 green:57/255.0 blue:36/255.0 alpha:1],
                        [UIColor colorWithRed:146/255.0 green:92/255.0 blue:147/255.0 alpha:1],
                        [UIColor colorWithRed:139/255.0 green:200/255.0 blue:103/255.0 alpha:1],
                        [UIColor colorWithRed:240/255.0 green:94/255.0 blue:116/255.0 alpha:1],
                        [UIColor colorWithRed:240/255.0 green:148/255.0 blue:32/255.0 alpha:1],
                        
    ];
    NSArray *pitches = @[@0,@1,@2,@3,@4,@5,@6];
    colors = [self shuffleArray:colors];
    pitches = [self shuffleArray:pitches];
    
    for (int i = 0; i< numCircles; i++) {
        TPEchoCircleView *circle = [[TPEchoCircleView alloc] initWithFrame:CGRectMake(0, 0, viewDimensions, viewDimensions)];
        circle.delegate = self;
        circle.backgroundColor = [UIColor clearColor];
        circle.color = colors[i];
        circle.pitch = pitches[i];
        float theta = 2.0*M_PI * i / numCircles;
        CGPoint point = CGPointMake(self.view.center.x + radius*cosf(theta), self.view.center.y + radius*sinf(theta));
        circle.center = point;
        [self.view addSubview:circle];
        [_circles addObject:circle];
    }
    [self generatePattern];
    [self moveMaxIndex];
    [self logLevelStartedWithAdditionalData:@{
                                              @"stage_type":self.data[@"stage_type"],
//                                              @"score_multiplier":self.data[@"score_multiplier"],
                                              @"score_multiplier":@1,
                                              }];
}

-(void)generatePattern
{
    int patternLength = 100;
    NSMutableArray *pattern = [@[] mutableCopy];
    for (int i=0; i<patternLength;i++) {
        [pattern addObject:[NSNumber numberWithInt:arc4random()%7]];
    }
    _pattern = pattern;
}

-(void)moveMaxIndex
{
    _currentMaxIndex++;
    _currentIndex = 0;
    NSLog(@"move index to : %i", _currentMaxIndex);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self playPattern:_pattern tillIndex:_currentMaxIndex];
        self.countdownLabel.text = [NSString stringWithFormat:@"%i", _currentMaxIndex];
    });
}


-(void)playPattern:(NSArray *)pattern tillIndex:(int) index
{
    self.view.userInteractionEnabled = NO;
    for (int i=0;i<index;i++) {
        [NSTimer scheduledTimerWithTimeInterval:0.75*i target:_circles[[pattern[i] intValue]] selector:@selector(play) userInfo:nil repeats:NO];
    }
    double delayInSeconds = 0.75*(index-1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.view.userInteractionEnabled = YES;
    });
}

-(void)tappedCircle:(TPEchoCircleView *)circle
{
    int circleIndex = [_circles indexOfObject:circle];
    int targetCircle = [_pattern[_currentIndex] intValue];
    if (_reverseMode) {
        targetCircle = [_pattern[_currentMaxIndex - _currentIndex - 1] intValue];
    }
    if (circleIndex == targetCircle) {
        _currentIndex++;
        [circle playSoundCorrect:YES];
    } else {
        [circle playSoundCorrect:NO];
        [self stageOver];
//        [[[UIAlertView alloc] initWithTitle:@"Wrong" message:@"You suck!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
    self.countdownLabel.text = [NSString stringWithFormat:@"%i", _currentMaxIndex - _currentIndex];
    if (_currentIndex == _currentMaxIndex) {
        [self moveMaxIndex];
    }
}

-(void)stageOver
{
    [self logLevelCompletedWithAdditionalData:nil summary:@{@"highest":[NSNumber numberWithInt:_currentMaxIndex]}];
    [super stageOver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)shuffleArray:(NSArray *)arrayToShuffle
{
    NSMutableArray *array = [arrayToShuffle mutableCopy];
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [array copy];
}

@end